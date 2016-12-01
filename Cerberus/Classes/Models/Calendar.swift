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

    private var timer: NSTimer?
    private let timerTickIntervalSec = 60.0

    init() {
        self.events = []
        self.eventStore = EKEventStore()
        self.calendar = NSCalendar.currentCalendar()
        self.selectedCalendars = nil

        self.date = NSDate()

        self.timer = NSTimer.scheduledTimerWithTimeInterval(timerTickIntervalSec, target: self, selector: #selector(Calendar.onTimerTick(_:)), userInfo: nil, repeats: true)

        registerNotificationObservers()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.timer?.invalidate()
    }

    private func registerNotificationObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()

        notificationCenter.addObserver(self,
            selector: #selector(Calendar.didChooseCalendarNotification(_:)),
            name:     NotifictionNames.CalendarModelDidChooseCalendarNotification.rawValue,
            object:   nil
        )

        notificationCenter.addObserver(self,
            selector: #selector(Calendar.didChangeEventNotification(_:)),
            name:     EKEventStoreChangedNotification,
            object:   nil
        )
    }

    @objc
    func didChooseCalendarNotification(notification: NSNotification) {
        self.selectedCalendars = notification.object as? [EKCalendar]
        self.update()
    }

    @objc
    func didChangeEventNotification(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName(NotifictionNames.CalendarModelDidChangeEventNotification.rawValue, object: nil)
    }

    @objc
    func onTimerTick(timer: NSTimer) {
        self.eventStore.refreshSourcesIfNecessary()

        self.date = NSDate()
        self.update()
    }

    func isAuthorized() -> Bool {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(.Event)

        return status == .Authorized
    }

    func authorize(completion: ((status: CalendarAuthorizationStatus) -> Void)?) {
        if isAuthorized() {
            fetchEvents()
            completion?(status: .Success)
            return
        }
        
        self.eventStore.requestAccessToEntityType(.Event, completion: { [weak self] (granted, error) -> Void in
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
                    let startDate = event.startDate
                    let endDate = event.endDate
                    
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

            if currentDateOffset < calEndDate {
                self.events.append(Event(startDate: currentDateOffset, endDate: calEndDate))
            }
        }

        NSNotificationCenter.defaultCenter().postNotificationName(NotifictionNames.CalendarModelDidChangeEventNotification.rawValue, object: nil)
    }

}
