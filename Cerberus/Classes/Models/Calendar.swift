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
    var targetCalendar: EKCalendar!
    
    init() {
        self.events = []
        self.eventStore = EKEventStore()
    }
    
    func isAuthorized() -> Bool {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)
        
        switch status {
            case EKAuthorizationStatus.NotDetermined:
                println("NotDetermined")
                return false
            case EKAuthorizationStatus.Denied:
                println("Denied")
                return false
            case EKAuthorizationStatus.Authorized:
                println("Authorized")
                return true
            case EKAuthorizationStatus.Restricted:
                println("Restricted")
                return false
            default:
                println("error")
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
        var myCalendar: NSCalendar = NSCalendar.currentCalendar()
        var myEventCalendars = self.eventStore.calendarsForEntityType(EKEntityTypeEvent)

        let oneDayAgoComponents: NSDateComponents = NSDateComponents()
        oneDayAgoComponents.day = -1
        
        let oneDayAgo: NSDate = myCalendar.dateByAddingComponents(oneDayAgoComponents,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros
        )!
        
        let oneDayFromNowComponents: NSDateComponents = NSDateComponents()
        oneDayFromNowComponents.year = 1
        
        let oneDayFromNow: NSDate = myCalendar.dateByAddingComponents(oneDayFromNowComponents,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros
        )!
        
        var predicate = self.eventStore.predicateForEventsWithStartDate(oneDayAgo,
            endDate: oneDayFromNow,
            calendars: nil
        )
        
        for event in self.eventStore.eventsMatchingPredicate(predicate) {
            self.events.append(Event(title: event.title ?? "(No title)"))
        }
    }
}