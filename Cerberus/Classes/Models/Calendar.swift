import Foundation
import EventKit

enum CalendarAuthorizationStatus {
    case Success
    case Error
}

final class Calendar {
    var events: [Event]!

    var eventStore: EKEventStore!
    var calendar: NSCalendar!

    init() {
        self.events = []
        self.eventStore = EKEventStore()
        self.calendar = NSCalendar.currentCalendar()
    }
    
    func isAuthorized() -> Bool {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)

        return status == .Authorized
    }

    func authorize(completion: ((status: CalendarAuthorizationStatus) -> Void)?) {
        if isAuthorized() {
            fetchEvents()
            completion?(status: .Success)
            return
        }
        
        self.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { [weak self] (granted, error) -> Void in
            if granted {
                self?.fetchEvents()
                completion?(status: .Success)
                return
            } else {
                completion?(status: .Error)
            }
        })
    }

    private func fetchEvents() {
        let now       = NSDate()
        let predicate = self.eventStore.predicateForEventsWithStartDate(30.days.ago, endDate: now, calendars: nil) // FIXME: ofDate: now

        if let matchingEvents = self.eventStore.eventsMatchingPredicate(predicate) {
            for event in matchingEvents {
                if event.startDate == nil || event.endDate == nil {
                    continue
                }
                self.events.append(Event.fromEKEvent(event as! EKEvent))
            }
        }
    }
}