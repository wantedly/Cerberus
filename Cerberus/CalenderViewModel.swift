import EventKit
import RxSwift
import RxCocoa

class CalendarViewModel {
    
    // Input
    let calendersButtonItemDidTap = PublishSubject<Void>()
    let applicationDidBecomeActive = PublishSubject<Void>()
    let applicationSignificantTimeChange = PublishSubject<Void>()
    
    // Output
    let events: Observable<[Event]>
    
    init(calendarService: CalendarService, wireframe: Wireframe) {
        let choosedCalendars = calendersButtonItemDidTap
            .flatMapFirst {
                calendarService.requestAccessToEvent()
                    .do(onError: { wireframe.prompt(for: $0) })
                    .flatMap { _ in
                        // Presents a calendar chooser to show a error message even if the requesting access is denied.
                        calendarService.presentCalendarChooserForEvent(in: wireframe.rootViewController)
                    }
            }
        
        let loadedCalendars = Observable
            .merge(
                .just(), // Emits an event immediately.
                applicationDidBecomeActive,
                applicationSignificantTimeChange,
                calendarService.eventStoreChanged
            )
            .flatMapFirst {
                calendarService.requestAccessToEvent()
                    .do(onError: { wireframe.prompt(for: $0) })
                    .flatMap { granted -> Observable<[EKCalendar]> in
                        if let savedCalendars = calendarService.loadCalendars(), granted {
                            return .just(savedCalendars)
                        }
                        return .empty()
                    }
            }
        
        events = Observable
            .merge (
                choosedCalendars,
                loadedCalendars
            )
            .flatMap { calendarService.fetchTodayEvents(from: $0) }
    }
}
