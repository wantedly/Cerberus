import Foundation
import EventKit
import Timepiece

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

    func todaysEvents(date: NSDate) -> [Event] {
        var res: [Event] = []
        var cur = date.beginningOfDay
        var endOfDay = cur + 1.day
        for event in self.events {
            let start = event.startDate, end = event.endDate
            if start < cur {
                continue
            } else if start >= endOfDay {
                break
            }
            if cur < start {
                res.append(Event(title: "Available", startDate: cur, endDate: start, available: true))
            }
            if end > endOfDay {
                res.append(Event(title: event.title, startDate: event.startDate, endDate: endOfDay, available: event.available))
            } else {
                res.append(event)
            }
            cur = end
        }
        if cur < endOfDay {
            res.append(Event(title: "Available", startDate: cur, endDate: endOfDay, available: true))
        }
        return res
    }

    private func fetchEvents() {
        let now       = NSDate()
        let predicate = self.eventStore.predicateForEventsWithStartDate(30.days.ago, endDate: 30.days.later, calendars: nil)

        if let matchingEvents = self.eventStore.eventsMatchingPredicate(predicate) {
            for event in matchingEvents {
                if event.startDate == nil || event.endDate == nil {
                    continue;
                }

                self.events.append(
                    Event(title: event.title ?? "(No title)",
                          startDate: event.startDate,
                          endDate:event.endDate
                    ))

            }
        }
    }

}