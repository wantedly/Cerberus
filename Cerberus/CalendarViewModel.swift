import EventKit
import EventKitUI
import RxSwift
import RxCocoa

class CalendarViewModel {

    // Input
    let calendarsButtonItemDidTap = PublishSubject<Void>()
    let applicationDidBecomeActive = PublishSubject<Void>()
    let applicationSignificantTimeChange = PublishSubject<Void>()

    // Output
    let events: Driver<[Event]>

    init(calendarService: CalendarServiceType, wireframe: WireframeType, shouldStartImmediately: Bool = true) {
        events = Observable
            .merge(
                Observable
                    .merge(
                        shouldStartImmediately ? .just(Void()) : .empty(),
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
                            return type(of: calendarService).chooseCalendars(with: calendarService.calendarChooserForEvent, in: wireframe.rootViewController)
                        }

                        if let savedCalendars = calendarService.loadCalendars(), shouldLoadAutomaticallyIfSaved {
                            return .just(savedCalendars)
                        }

                        return type(of: calendarService).chooseCalendars(with: calendarService.calendarChooserForEvent, in: wireframe.rootViewController, defaultCalendars: calendarService.loadCalendars())
                            .do(onNext: { type(of: calendarService).saveCalendars($0) })
                    }
            }
            .flatMap { calendarService.fetchTodayEvents(from: $0) }
            .asDriver(onErrorDriveWith: .empty())
    }
}
