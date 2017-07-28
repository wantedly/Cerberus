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
        events = Observable
            .merge(
                calendersButtonItemDidTap.map { true },
                Observable.merge(
                    .just(), // Emits an event immediately.
                    applicationDidBecomeActive,
                    applicationSignificantTimeChange,
                    calendarService.eventStoreChanged
                ).map { false }
            )
            .flatMapFirst { skipLoad in
                calendarService.requestAccessToEvent()
                    .do(onError: { wireframe.prompt(for: $0) })
                    .flatMap { granted -> Observable<[EKCalendar]> in
                        if let savedCalendars = calendarService.loadCalendars(), !skipLoad && granted {
                            return .just(savedCalendars)
                        }

                        // Presents a calendar chooser to show a error message even if the requesting access is denied.
                        return calendarService.presentCalendarChooserForEvent(in: wireframe.rootViewController)
                    }
            }
            .flatMap { calendarService.fetchTodayEvents(from: $0) }
    }
}
