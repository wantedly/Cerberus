import RxSwift
import RxCocoa

class CalendarViewModel {
    
    // Input
    let calendersButtonItemDidTap = PublishSubject<Void>()
    
    // Output
    let events: Observable<[Event]>
    
    init(calendarService: CalendarService) {
        let choosedCalendars = calendersButtonItemDidTap
            .flatMapLatest { _ in calendarService.requestAccessToEvent() }
            .flatMapLatest { _ in calendarService.chooseCalendarForEvent() }
            .shareReplay(1)
        
        events = Observable
            .merge(
                choosedCalendars,
                calendarService.eventStoreChanged.withLatestFrom(choosedCalendars)
            )
            .flatMap { calendarService.fetchTodayEvents(from: $0) }
    }    
}
