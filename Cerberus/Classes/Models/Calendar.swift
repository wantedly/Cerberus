//
//  Calendar.swift
//  Cerberus
//
//  Created by Yuki Iwanaga on 6/6/15.
//  Copyright (c) 2015 Wantedly, Inc. All rights reserved.
//

import Foundation
import EventKit

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
        
        switch status {
            case .Authorized:
                println("Authorized")
                return true
            default:
                println(status)
                return false
        }
    }

    func authorize() {
        if isAuthorized() {
            fetchEvents()
            return
        }
        
        self.eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: { [weak self] (granted, error) -> Void in
            if granted {
                self?.fetchEvents()
                return
            } else {
                /* FIXME
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    
                    myAlert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                */
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