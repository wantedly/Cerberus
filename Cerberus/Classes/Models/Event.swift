import Foundation
import EventKit

final class Event {
    var title: String = ""
    var location: String?
    
    var startDate: NSDate
    var endDate: NSDate

    var attendees: [User] = []
    var available = false

    init(title: String, startDate: NSDate, endDate: NSDate, available: Bool = false) {
        self.title     = title
        self.startDate = startDate
        self.endDate   = endDate
        self.available = available
    }

    class func fromEKEvent(eventOfEventKit: EKEvent) -> Event {
        let event = Event(
            title:     eventOfEventKit.title ?? "No title",
            startDate: eventOfEventKit.startDate,
            endDate:   eventOfEventKit.endDate
        )

        return event
    }
}