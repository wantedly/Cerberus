import EventKit
import EventKitUI
import RxSwift
import RxCocoa

class CalendarService {
    
    struct Constant {
        static let minimumMinutesOfEmptyEvent = 5
    }
    
    private let eventStore = EKEventStore()
    
    var eventStoreChanged: Observable<Void> {
        return NotificationCenter.default.rx.notification(.EKEventStoreChanged, object: eventStore).map { _ in }
    }
    
    func requestAccessToEvent() -> Observable<Bool> {
        return eventStore.rx.requestAccess(to: .event)
    }
    
    func presentCalendarChooserForEvent(in parent: UIViewController?) -> Observable<[EKCalendar]> {
        return Observable.create { observer in
            let calendarChooser = EKCalendarChooser(selectionStyle: .single, displayStyle: .allCalendars, entityType: .event, eventStore: self.eventStore)
            calendarChooser.showsDoneButton = true
            
            if let savedCalendars = CalendarService.loadCalendars(with: self.eventStore) {
                calendarChooser.selectedCalendars = Set(savedCalendars)
            }
            
            let presentDisposable = calendarChooser.rx.present(in: parent)
                .subscribe(onCompleted: {
                    observer.on(.completed)
                })
            
            let changeDisposable = calendarChooser.rx.selectionDidChange
                .map { Array(calendarChooser.selectedCalendars) }
                .do(onNext: { CalendarService.saveCalendars($0) })
                .subscribe(onNext: { calendars in
                    observer.on(.next(calendars))
                })
            
            return Disposables.create(presentDisposable, changeDisposable)
        }
    }
    
    func loadCalendars() -> [EKCalendar]? {
        return CalendarService.loadCalendars(with: eventStore)
    }
    
    private static func loadCalendars(with eventStore: EKEventStore) -> [EKCalendar]? {
        let calendarIdentifiers = UserDefaults.standard.value(for: UserDefaultsKeys.calendarIdentifiers)
        return calendarIdentifiers?.flatMap { eventStore.calendar(withIdentifier: $0) }
    }
    
    private static func saveCalendars(_ calendars: [EKCalendar]) {
        let calendarIdentifiers = calendars.map { $0.calendarIdentifier }
        UserDefaults.standard.set(value: calendarIdentifiers, for: UserDefaultsKeys.calendarIdentifiers)
    }
    
    func fetchTodayEvents(from calendars: [EKCalendar]) -> Observable<[Event]> {
        guard let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) else {
            return .empty()
        }
        
        guard let endDate = Calendar.current.date(byAdding: DateComponents(hour: 23, minute: 59, second: 59), to: startDate) else {
            return .empty()
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let calendarEvents = eventStore.events(matching: predicate)
        let events = CalendarService.makeEvents(from: calendarEvents, start: startDate, end: endDate)
        return .just(events)
    }
    
    static func makeEvents(from calendarEvents: [EKEvent], start: Date, end: Date) -> [Event] {
        var events = [Event]()
        var maximumDate = start
        
        let sortedEvents = calendarEvents.sorted(by: { $0.0.startDate < $0.1.startDate })
        sortedEvents.forEach { calendarEvent in
            if let minuteDiff = minuteDiff(from: maximumDate, to: calendarEvent.startDate), minuteDiff > Constant.minimumMinutesOfEmptyEvent {
                events.append(Event(.empty, from: maximumDate, to: calendarEvent.startDate))
            }
            events.append(Event(calendarEvent))
            maximumDate = max(maximumDate, calendarEvent.endDate)
        }
        if let minuteDiff = minuteDiff(from: maximumDate, to: end), minuteDiff > Constant.minimumMinutesOfEmptyEvent {
            events.append(Event(.empty, from: maximumDate, to: end))
        }
        return events
    }
}

private func minuteDiff(from start: Date, to end: Date) -> Int? {
    return Calendar.current.dateComponents([.minute], from: start, to: end).minute
}
