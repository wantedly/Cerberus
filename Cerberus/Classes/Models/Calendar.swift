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
        let startDate = self.calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: 30.days.ago, options: nil) // FIXME: ofDate: now
        let endDate   = self.calendar.dateBySettingHour(23, minute: 59, second: 59, ofDate: now, options: nil)
        let predicate = self.eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: nil)

        if let matchingEvents = self.eventStore.eventsMatchingPredicate(predicate) {
            for event in matchingEvents {
                self.events.append(Event(title: event.title ?? "(No title)"))
            }
        }
    }
}