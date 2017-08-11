import EventKit
import EventKitUI
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
                    .merge(
                        .just(), // Emits an event immediately.
                        applicationDidBecomeActive,
                        applicationSignificantTimeChange,
                        calendarService.eventStoreChanged
                    )
                    .map { true },
                Observable
                    .merge(calendarsButtonItemDidTap)
                    .map { false }
            )
            .flatMapFirst { shouldLoadAutomaticallyIfSaved in
                calendarService.requestAccessToEvent()
                    .do(onError: { wireframe.prompt(for: $0) })
                    .flatMap { granted -> Observable<Set<EKCalendar>> in
                        if !granted {
                            // Presents a calendar chooser to show a error message.
                            return CalendarService.chooseCalendars(with: calendarService.calendarChooserForEvent, in: wireframe.rootViewController)
                        }

                        if let savedCalendars = calendarService.loadCalendars(), shouldLoadAutomaticallyIfSaved {
                            return .just(savedCalendars)
                        }
                        
                        return CalendarService.chooseCalendars(with: calendarService.calendarChooserForEvent, in: wireframe.rootViewController, defaultCalendars: calendarService.loadCalendars())
                            .do(onNext: { CalendarService.saveCalendars($0) })
                    }
            }
            .flatMap { calendarService.fetchTodayEvents(from: $0) }
    }
}
