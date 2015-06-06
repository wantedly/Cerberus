import Foundation
import EventKit

final class Event {
    var title: String = ""
    var location: String?
    
    var startDate: NSDate
    var endDate: NSDate

    var available: Bool = false
    var attendees: [User] = []

    init(title: String, startDate: NSDate, endDate: NSDate, available: Bool = false) {
        self.title     = title
        self.startDate = startDate
        self.endDate   = endDate
        self.available = available
    }

    class func fromEKEvent(_event: EKEvent) -> Event {
        let event = Event(
            title:     _event.title ?? "No title",
            startDate: _event.startDate,
            endDate:   _event.endDate
        )

        return event
    }
}