import UIKit
import EventKit
import EventKitUI

class MainViewController: UIViewController, EKCalendarChooserDelegate {

    weak var timelineCollectionViewController: TimelineCollectionViewController?
    weak var eventsCollectionViewController: EventsCollectionViewController?
    var calendarChooser: EKCalendarChooser!

    var KVOContext = "MainViewControllerKVOContext"
    let contentOffsetKeyPath = "contentOffset"

    deinit {
        self.timelineCollectionViewController?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
        self.eventsCollectionViewController?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.destinationViewController {
        case let timelineCollectionViewController as TimelineCollectionViewController:
            self.timelineCollectionViewController = timelineCollectionViewController
            self.timelineCollectionViewController?.collectionView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .New, context: &KVOContext)
        case let eventsCollectionViewController as EventsCollectionViewController:
            self.eventsCollectionViewController = eventsCollectionViewController
            self.eventsCollectionViewController?.collectionView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .New, context: &KVOContext)
        default:
            break
        }
    }

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
        super.viewDidLoad()

        // FIXME: Unbalanced calls to begin/end appearance transitions
        presentCalendarChooser()
    }

    func presentCalendarChooser() {
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

    // MARK: Key Value Observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &KVOContext && keyPath == contentOffsetKeyPath {
            if let collectionView = object as? UICollectionView {
                var anotherCollectionViewController: UICollectionViewController?
                if collectionView == timelineCollectionViewController?.collectionView {
                    anotherCollectionViewController = eventsCollectionViewController
                } else if collectionView == eventsCollectionViewController?.collectionView {
                    anotherCollectionViewController = timelineCollectionViewController
                }

                if let anotherCollectionView = anotherCollectionViewController?.collectionView {
                    if anotherCollectionView.contentOffset.y != collectionView.contentOffset.y {
                        anotherCollectionView.contentOffset = collectionView.contentOffset
                    }
                }
            }
        }
    }
}