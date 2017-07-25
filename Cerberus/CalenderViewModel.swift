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
            .flatMapLatest { _ in calendarService.chooseCalendarForEvent() }
            .shareReplay(1)
        
        eventSections = Observable
            .merge(
                choosedCalendars,
                calendarService.eventStoreChanged.withLatestFrom(choosedCalendars)
            )
            .flatMap { calendarService.fetchTodayEvents(from: $0) }
            .map { [EventSection(model: (), items: $0)] }
    }    
}
