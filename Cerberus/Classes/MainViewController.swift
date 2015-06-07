import UIKit
import EventKit
import EventKitUI

class MainViewController: UIViewController, EKCalendarChooserDelegate {

    var calendarChooser: EKCalendarChooser!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navCtrl = self.navigationController {
            let bgImage = UIImage(named: "background")
            navCtrl.navigationBar.setBackgroundImage(bgImage, forBarMetrics: UIBarMetrics.Default)
        }
        setNavbarTitle()
    }

    func setNavbarTitle(date: NSDate = NSDate()) {
        self.title = date.stringFromFormat("EEEE, MMMM d, yyyy")
    }

    override func viewDidLoad() {
        let calendarChooser = EKCalendarChooser(
            selectionStyle: EKCalendarChooserSelectionStyleSingle,
            displayStyle:   EKCalendarChooserDisplayAllCalendars,
            entityType:     EKEntityTypeEvent,
            eventStore:     EKEventStore()
        )
        calendarChooser.delegate = self

        let navigationController = UINavigationController(rootViewController: calendarChooser)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }

    func calendarChooserSelectionDidChange(calendarChooser: EKCalendarChooser!) {
        var calendars: [EKCalendar] = []
        
        for calendar in calendarChooser.selectedCalendars {
            calendars.append(calendar as! EKCalendar)
        }

        NSNotificationCenter.defaultCenter().postNotificationName(NotifictionNames.MainViewControllerDidChooseCalendarNotification.rawValue, object: calendars)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
}