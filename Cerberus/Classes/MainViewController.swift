import UIKit
import EventKit
import EventKitUI
import Timepiece

class MainViewController: UIViewController, EKCalendarChooserDelegate {

    weak var timelineCollectionViewController: TimelineCollectionViewController?
    weak var eventsCollectionViewController: EventsCollectionViewController?
    var calendarChooser: EKCalendarChooser!

    private var kvoContextForTimelineCollectionViewController = "kvoContextForTimelineCollectionViewController"
    private var kvoContextForEventsCollectionViewController = "kvoContextForEventsCollectionViewController"

    private let contentOffsetKeyPath = "contentOffset"

    deinit {
        self.timelineCollectionViewController?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
        self.eventsCollectionViewController?.removeObserver(self, forKeyPath: contentOffsetKeyPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.destinationViewController {
        case let timelineCollectionViewController as TimelineCollectionViewController:
            self.timelineCollectionViewController = timelineCollectionViewController
            self.timelineCollectionViewController?.collectionView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .New, context: &kvoContextForTimelineCollectionViewController)
        case let eventsCollectionViewController as EventsCollectionViewController:
            self.eventsCollectionViewController = eventsCollectionViewController
            self.eventsCollectionViewController?.collectionView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .New, context: &kvoContextForEventsCollectionViewController)
        default:
            break
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "background"), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(24)]
        updateNavigationBarTitle()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIApplicationDelegate.applicationSignificantTimeChange(_:)), name: UIApplicationSignificantTimeChangeNotification, object: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.calendarChooser == nil {
            presentCalendarChooser()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Private

    private func updateNavigationBarTitle() {
        let now = NSDate()
        title = now.stringFromFormat("EEEE, MMMM d, yyyy")
    }

    private func presentCalendarChooser() {
        self.calendarChooser = EKCalendarChooser(
            selectionStyle: EKCalendarChooserSelectionStyleSingle,
            displayStyle:   EKCalendarChooserDisplayAllCalendars,
            entityType:     EKEntityTypeEvent,
            eventStore:     EKEventStore()
        )
        self.calendarChooser.delegate = self

        let navigationController = UINavigationController(rootViewController: self.calendarChooser)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }

    // MARK: EKCalendarChooserDelegate

    func calendarChooserSelectionDidChange(calendarChooser: EKCalendarChooser!) {
        var calendars: [EKCalendar] = []

        if let selectedCalendarsSet = calendarChooser.selectedCalendars as? Set<EKCalendar> {
            calendars = Array(selectedCalendarsSet)
        }

        NSNotificationCenter.defaultCenter().postNotificationName(NotifictionNames.CalendarModelDidChooseCalendarNotification.rawValue, object: calendars)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIApplicationNotification
    
    func applicationSignificantTimeChange(notification: NSNotification) {
        updateNavigationBarTitle()
    }

    // MARK: Key Value Observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        var anotherCollectionViewController: UICollectionViewController?

        switch context {
        case &kvoContextForEventsCollectionViewController:
            anotherCollectionViewController = self.timelineCollectionViewController
        case &kvoContextForTimelineCollectionViewController:
            anotherCollectionViewController = self.eventsCollectionViewController
        default:
            return
        }

        if keyPath != contentOffsetKeyPath {
            return
        }

        if let anotherCollectionView = anotherCollectionViewController?.collectionView {
            if let point = change["new"] as? NSValue {
                let y = point.CGPointValue().y

                if anotherCollectionView.contentOffset.y != y {
                    anotherCollectionView.contentOffset.y = y
                }
            }
        }
    }
}
