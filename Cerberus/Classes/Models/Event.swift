import Foundation
import EventKit

final class Event {
    let title: String
    var startDate: NSDate
    var endDate: NSDate

    var location: Location?
    var attendees: [User]! = []
    let available: Bool

    init(title: String, startDate: NSDate, endDate: NSDate, available: Bool = false) {
        self.title     = title
        self.startDate = startDate
        self.endDate   = endDate
        self.available = available
    }

    class func fromEKEvent(eventOfEventKit: EKEvent) -> Event {
        let event = self(
            title:     eventOfEventKit.title ?? "No title",
            startDate: eventOfEventKit.startDate,
            endDate:   eventOfEventKit.endDate
        )

        event.location = Location.findOrCreate(eventOfEventKit.location)

        if let attendees = eventOfEventKit.attendees {
            for attendee in attendees {
                if let a = attendee as? EKParticipant {
                    switch a.participantType.value {
                    case EKParticipantTypePerson.value:
                        if a.participantStatus.value != EKParticipantStatusDeclined.value {
                            if let name = a.name, email = a.URL.resourceSpecifier {
                                event.attendees.append(User(name: name, email: email))
                            }
                        }

                    default:
                        // just ignore
                        println(a.participantType)
                    }
                }
            }
        }

        return event
    }

    class func createEmptyEvent(#startDate: NSDate, endDate: NSDate) -> Event {
        let event = self(
            title:     "Available",
            startDate: startDate,
            endDate:   endDate,
            available: true
        )

        return event
    }
}