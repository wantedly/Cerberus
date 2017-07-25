import EventKit
import RxSwift
import RxCocoa
import RxDataSources

typealias EventSection = SectionModel<Void, Event>

class CalendarViewModel {
    
    // Input
    let calendersButtonItemDidTap = PublishSubject<Void>()
    
    // Output
    let eventSections: Observable<[EventSection]>
    
    init(calendarService: CalendarService, wireframe: Wireframe) {
        let choosedCalendars = calendersButtonItemDidTap
            .flatMapLatest {
                calendarService.requestAccessToEvent()
                    .do(onError: { wireframe.prompt(for: $0) })
            }
            .flatMapLatest { _ in
                calendarService.presentCalendarChooserForEvent(in: wireframe.rootViewController)
            }
        
        let loadedCalendars = Observable
            .merge(
                NotificationCenter.default.rx.notification(.EKEventStoreChanged, object: calendarService.eventStore).map { _ in },
                NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive).map { _ in },
                NotificationCenter.default.rx.notification(.UIApplicationSignificantTimeChange).map { _ in }
            )
            .startWith(Void())
            .flatMapLatest {
                calendarService.requestAccessToEvent()
                    .flatMap { granted -> Observable<Void> in
                        granted ? .just() : .empty()
                    }
                    .do(onError: { wireframe.prompt(for: $0) })
            }
            .flatMap { () -> Observable<[EKCalendar]> in
                if let savedCalendars = calendarService.loadCalendars() {
                    return .just(savedCalendars)
                } else {
                    return calendarService.presentCalendarChooserForEvent(in: wireframe.rootViewController)
                }
            }
        
        eventSections = Observable
            .merge (
                choosedCalendars,
                loadedCalendars
            )
            .flatMap { calendarService.fetchTodayEvents(from: $0) }
            .map { [EventSection(model: (), items: $0)] }
    }
}
