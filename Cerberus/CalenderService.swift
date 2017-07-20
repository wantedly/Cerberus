import EventKit
import EventKitUI
import RxSwift
import RxCocoa

class CalendarService {
    
    private let eventStore = EKEventStore()
    
    struct Constant {
        static let minimumMinutesOfEmptyEvent = 5
    }
    
    var eventStoreChanged: Observable<Void> {
        return NotificationCenter.default.rx.notification(.EKEventStoreChanged, object: eventStore).map { _ in }
    }
    
    func requestAccessToEvent() -> Observable<Bool> {
        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .notDetermined {
            return eventStore.rx.requestAccess(to: .event)
        } else {
            return .just(status == .authorized)
        }
    }
    
    func chooseCalendarForEvent() -> Observable<[EKCalendar]> {
        let calendarChooser = EKCalendarChooser(selectionStyle: .single, displayStyle: .allCalendars, entityType: .event, eventStore: eventStore)
        calendarChooser.showsDoneButton = true
        
        return calendarChooser.rx.present(in: UIApplication.shared.keyWindow?.rootViewController)
            .flatMap { $0.rx.selectionDidChange }
            .map { _ in Array(calendarChooser.selectedCalendars) }
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
