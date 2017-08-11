import EventKit
import RxSwift

class CalendarViewModel {

    // Input
    let calendarsButtonItemDidTap = PublishSubject<Void>()
    let applicationDidBecomeActive = PublishSubject<Void>()
    let applicationSignificantTimeChange = PublishSubject<Void>()

    // Output
    let events: Observable<[Event]>

    init(calendarService: CalendarService, wireframe: Wireframe) {
        events = Observable
            .merge(
                Observable
                    .merge(calendarsButtonItemDidTap)
                    .map { true },
                Observable
                    .merge(
                        .just(), // Emits an event immediately.
                        applicationDidBecomeActive,
                        applicationSignificantTimeChange,
                        calendarService.eventStoreChanged
                    )
                    .map { false }
            )
            .flatMapFirst { skipLoad in
                calendarService.requestAccessToEvent()
                    .do(onError: { wireframe.prompt(for: $0) })
                    .flatMap { granted -> Observable<[EKCalendar]> in
                        if let savedCalendars = calendarService.loadCalendars(), !skipLoad && granted {
                            return .just(savedCalendars)
                        }

                        // Presents a calendar chooser to show a error message even if the requesting access is denied.
                        return CalendarService.chooseCalendars(with: calendarService.calendarChooser, in: wireframe.rootViewController, defaultCalendars: calendarService.loadCalendars())
                    }
                    .flatMap { calendarService.fetchTodayEvents(from: $0) }
            }
    }
}
