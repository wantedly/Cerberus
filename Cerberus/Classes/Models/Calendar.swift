import Foundation
import EventKit
import Timepiece

enum CalendarAuthorizationStatus {
    case Success
    case Error
}

final class Calendar {

    private let eventStore: EKEventStore!
    private let calendar: NSCalendar!

    var events: [Event]!

    var date: NSDate!

    static var calendars: [EKCalendar]? = nil

    init() {
        self.events = []
        self.eventStore = EKEventStore()
        self.calendar = NSCalendar.currentCalendar()

        self.date = NSDate()
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

    func update() {
        if isAuthorized() {
            fetchEvents()
        }
    }

    private func fetchEvents() {
        self.events.removeAll(keepCapacity: true)

        let calStartDate = self.date.beginningOfDay
        let calEndDate   = calStartDate + 1.day

        if let calendars = Calendar.calendars {
            let predicate = self.eventStore.predicateForEventsWithStartDate(calStartDate, endDate: calEndDate, calendars: calendars)

            var currentDateOffset = calStartDate

            if let matchingEvents = self.eventStore.eventsMatchingPredicate(predicate) {
                for event in matchingEvents {
                    if let startDate = event.startDate, endDate = event.endDate {
                        if startDate < currentDateOffset {
                            continue
                        } else if startDate >= calEndDate {
                            break
                        }

                        if currentDateOffset < startDate {
                            self.events.append(Event.createEmptyEvent(startDate: currentDateOffset, endDate: startDate))
                        }

                        let event = Event.fromEKEvent(event as! EKEvent)

                        if endDate > calEndDate {
                            event.endDate = calEndDate
                        }

                        self.events.append(event)

                        currentDateOffset = endDate
                    }
                }
            }

            if currentDateOffset < calEndDate {
                self.events.append(Event.createEmptyEvent(startDate: currentDateOffset, endDate: calEndDate))
            }
        }
    }

}