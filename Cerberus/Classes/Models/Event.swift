import Foundation
import EventKit

final class Event {
    let title: String
    var startDate: NSDate
    var endDate: NSDate

    var attendees = [User]()
    private var available = false

    init(title: String, startDate: NSDate, endDate: NSDate) {
        self.title     = title
        self.startDate = startDate
        self.endDate   = endDate
    }

    init(startDate: NSDate, endDate: NSDate) {
        self.title     = "Available"
        self.startDate = startDate
        self.endDate   = endDate
        self.available = true
    }

    class func fromEKEvent(eventOfEventKit: EKEvent) -> Event {
        let event = self(
            title:     eventOfEventKit.title ?? "No title",
            startDate: eventOfEventKit.startDate,
            endDate:   eventOfEventKit.endDate
        )

        if let attendees = eventOfEventKit.attendees as? [EKParticipant] {
            for attendee in attendees {
                switch attendee.participantType.value {
                case EKParticipantTypePerson.value:
                    if attendee.participantStatus.value != EKParticipantStatusDeclined.value {
                        if let name = attendee.name, email = attendee.URL.resourceSpecifier {
                            event.attendees.append(User(name: name, email: email))
                        }
                    }

                default:
                    break
                }
            }
        }

        return event
    }

    func isAvailable() -> Bool {
        return self.available
    }

    func span() -> Int {
        var end = endDate.hour * 60 + endDate.minute
        if end == 0 {
            end = 24 * 60
        }
        let start = startDate.hour * 60 + startDate.minute
        return end - start
    }
}