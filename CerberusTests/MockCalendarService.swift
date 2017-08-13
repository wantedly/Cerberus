import EventKit
import EventKitUI
import RxSwift

@testable import Cerberus

class MockCalendarService: CalendarServiceType {
    var eventStoreChanged: Observable<Void> { return .empty() }
    var calendarChooserForEvent: EKCalendarChooser { return EKCalendarChooser() }

    var requestAccessToEventClosure: () -> Observable<Bool> = { return .empty() }
    func requestAccessToEvent() -> Observable<Bool> { return requestAccessToEventClosure() }

    static var chooseCalendarsClosure: (_ chooser: EKCalendarChooser, _ parent: UIViewController?, _ defaultCalendars: Set<EKCalendar>?) -> Observable<Set<EKCalendar>> = { _, _, _ in return .empty() }
    static func chooseCalendars(with chooser: EKCalendarChooser, in parent: UIViewController?, defaultCalendars: Set<EKCalendar>?) -> Observable<Set<EKCalendar>> {
        return chooseCalendarsClosure(chooser, parent, defaultCalendars)
    }

    var loadedCalendarsClosure: () -> Set<EKCalendar>? = { return nil }
    func loadCalendars() -> Set<EKCalendar>? { return loadedCalendarsClosure() }

    static var savedCalendarsClosure: (_ calendars: Set<EKCalendar>) -> Void = { _ in }
    static func saveCalendars(_ calendars: Set<EKCalendar>) { savedCalendarsClosure(calendars) }

    var fetchTodayEventsClosure: (_ calendars: Set<EKCalendar>) -> Observable<[Cerberus.Event]> = { _ in return .empty() }
    func fetchTodayEvents(from calendars: Set<EKCalendar>) -> Observable<[Cerberus.Event]> { return fetchTodayEventsClosure(calendars) }
}
