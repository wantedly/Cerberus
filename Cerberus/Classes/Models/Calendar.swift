import Foundation
import EventKit
import Timepiece

enum CalendarAuthorizationStatus {
    case Success
    case Error
}

final class Calendar {

    var date: NSDate

    private let eventStore: EKEventStore!
    private let calendar: NSCalendar!
    private var selectedCalendars: [EKCalendar]?

    var events: [Event]

    init() {
        self.events = []
        self.eventStore = EKEventStore()
        self.calendar = NSCalendar.currentCalendar()
        self.selectedCalendars = nil

        self.date = NSDate()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didChooseCalendarNotification:",
            name:     NotifictionNames.MainViewControllerDidChooseCalendarNotification.rawValue,
            object:   nil
        )
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc
    func didChooseCalendarNotification(notification: NSNotification) {
        self.selectedCalendars = notification.object as? [EKCalendar]
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

        if let calendars = self.selectedCalendars {
            let predicate = self.eventStore.predicateForEventsWithStartDate(calStartDate, endDate: calEndDate, calendars: calendars)

            var currentDateOffset = calStartDate

            if let matchingEvents = self.eventStore.eventsMatchingPredicate(predicate) as? [EKEvent] {
                for event in matchingEvents {
                    if let startDate = event.startDate, endDate = event.endDate {
                        if startDate < currentDateOffset {
                            continue
                        } else if startDate >= calEndDate {
                            break
                        }

                        if currentDateOffset < startDate {
                            self.events.append(Event(startDate: currentDateOffset, endDate: startDate))
                        }

                        let event = Event(fromEKEvent: event)

                        if endDate > calEndDate {
                            event.endDate = calEndDate
                        }

                        self.events.append(event)

                        currentDateOffset = endDate
                    }
                }
            }

            if currentDateOffset < calEndDate {
                self.events.append(Event(startDate: currentDateOffset, endDate: calEndDate))
            }
        }
    }

}