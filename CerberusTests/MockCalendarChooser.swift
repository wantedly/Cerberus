import EventKit
import EventKitUI

class MockCalendarChooser: EKCalendarChooser {
    private static let calendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
    var setCalendars: Set<EKCalendar>?

    override var selectedCalendars: Set<EKCalendar> {
        get { return MockCalendarChooser.calendars }
        set { setCalendars = newValue }
    }
}
