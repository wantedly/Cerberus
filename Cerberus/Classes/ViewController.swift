//
//  ViewController.swift
//  Cerberus
//
//  Created by Jiro Nagashima on 2015/06/06.
//  Copyright (c) 2015年 Wantedly, Inc. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    var myEventStore: EKEventStore!
    var myEvents: NSArray!
    var myTargetCalendar: EKCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        myEventStore = EKEventStore()
        allowAuthorization()
        let events: [EKEvent] = getEvents()
        NSLog("%@", events)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getAuthorization_status() -> Bool {
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

    func allowAuthorization() {
        if getAuthorization_status() {
            return
        } else {
            myEventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: {
                (granted , error) -> Void in
                if granted {
                    return
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        let myAlert = UIAlertController(title: "許可されませんでした", message: "Privacy->App->Reminderで変更してください", preferredStyle: UIAlertControllerStyle.Alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

                        myAlert.addAction(okAction)
                        self.presentViewController(myAlert, animated: true, completion: nil)
                    })
                }
            })
        }
    }

    func getEvents() -> [EKEvent] {
        var myCalendar: NSCalendar = NSCalendar.currentCalendar()
        var myEventCalendars = myEventStore.calendarsForEntityType(EKEntityTypeEvent)

        let oneDayAgoComponents: NSDateComponents = NSDateComponents()
        oneDayAgoComponents.day = -1

        let oneDayAgo: NSDate = myCalendar.dateByAddingComponents(oneDayAgoComponents,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)!

        let oneDayFromNowComponents: NSDateComponents = NSDateComponents()
        oneDayFromNowComponents.year = 1

        let oneDayFromNow: NSDate = myCalendar.dateByAddingComponents(oneDayFromNowComponents,
            toDate: NSDate(),
            options: NSCalendarOptions.allZeros)!

        var predicate = NSPredicate()

        predicate = myEventStore.predicateForEventsWithStartDate(oneDayAgo,
            endDate: oneDayFromNow,
            calendars: nil)

        var events = myEventStore.eventsMatchingPredicate(predicate) as! [EKEvent]
        return events
    }

}

