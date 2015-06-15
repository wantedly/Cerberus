import UIKit
import EventKit
import Async
import Timepiece
import EasyAnimation

class EventsCollectionViewController: UICollectionViewController {

    var calendar: Calendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendar = Calendar()

        self.calendar.authorize { status in
            switch status {
            case .Error:
                Async.background {
                    let alert = UIAlertController(
                        title: "許可されませんでした",
                        message: "Privacy->App->Reminderで変更してください",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )

                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            case .Success:
                println("Authorized")
            }
        }

        let nib = UINib(nibName: XibNames.EventCollectionViewCell.rawValue, bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: CollectionViewCellreuseIdentifier.EventCell.rawValue)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventStoreChanged:", name: EKEventStoreChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChooseCalendarNotification:", name: NotifictionNames.MainViewControllerDidChooseCalendarNotification.rawValue, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Update calendar events

    func updateCalendarEvents() {
        self.calendar?.update()
        self.collectionView?.reloadData()

        NSNotificationCenter.defaultCenter().postNotificationName(NotifictionNames.TimelineCollectionViewControllerDidUpdateTimeline.rawValue, object: nil)
    }

    func eventStoreChanged(notification: NSNotification) {
        updateCalendarEvents()
    }

    func didChooseCalendarNotification(notification: NSNotification) {
        updateCalendarEvents()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendar.events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellreuseIdentifier.EventCell.rawValue, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.eventModel = self.calendar.events[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let eventsCollectionViewFlowLayout = collectionViewLayout as! EventsCollectionViewFlowLayout
        let event = self.calendar.events[indexPath.row]
        return eventsCollectionViewFlowLayout.sizeForEvent(event)
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let (visibles, nearestCenter) = getVisibleCellsAndNearestCenterCell()

        let eventsCollectionViewFlowLayout = self.collectionViewLayout as! EventsCollectionViewFlowLayout

        for cellInfo in visibles {
            let cell = cellInfo.cell as! EventCollectionViewCell

            cell.hidden = false

            let event = self.calendar.events[cellInfo.row]

            var dy: CGFloat     = 0.0
            var height: CGFloat = eventsCollectionViewFlowLayout.sizeForEvent(event).height
            var alpha: CGFloat  = 0.0

            if cell == nearestCenter.cell {
                height += TimelineHeight
                alpha = 1.0
            } else {
                dy = (cellInfo.row < nearestCenter.row ? -1 : +1) * TimelineHeight / 2
                alpha = 0.5
            }

            UIView.animateWithDuration(0.6,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.0,
                options: .CurveEaseInOut,
                animations: { () -> Void in
                    cell.bounds.size.height = height
                    cell.transform = CGAffineTransformMakeTranslation(0, dy)
                    cell.alpha = alpha
                },
                completion: nil
            )
        }
    }
}
