import UIKit
import EventKit
import Async
import Timepiece

class EventsCollectionViewController: UICollectionViewController {

    private typealias EventCellInfo = (cell: UICollectionViewCell, row: Int, height: CGFloat, deviation: CGFloat)

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
        let collectionViewHeight = self.collectionView!.bounds.height
        let collectionViewY = self.collectionView!.frame.origin.y

        var cellInfos = [EventCellInfo]()
        var nearestCenter: EventCellInfo!

        for indexPath in self.collectionView!.indexPathsForVisibleItems() {
            let cell     = self.collectionView!.cellForItemAtIndexPath(indexPath as! NSIndexPath)!
            let cellRect = self.collectionView!.convertRect(cell.frame, toView: self.collectionView?.superview)

            var height = cellRect.height
            var y      = cellRect.origin.y

            if y < collectionViewY {
                height -= collectionViewY - y
                y       = 0
            }

            let deviation = (y + height / 2) / collectionViewHeight - 0.5

            let cellInfo: EventCellInfo = (
                cell:      cell,
                row:       indexPath.row,
                height:    height,
                deviation: deviation
            )

            cellInfos.append(cellInfo)

            if abs(nearestCenter?.deviation ?? CGFloat.infinity) > abs(deviation) {
                nearestCenter = cellInfo
            }
        }

        for cellInfo in cellInfos {
            cellInfo.cell.hidden = false

            var dy: CGFloat     = 0.0
            var height: CGFloat = cellInfo.cell.frame.height
            var alpha: CGFloat  = 0.0

            if cellInfo.cell == nearestCenter.cell {
                height += 100
                alpha = 1.0
            } else {
                var diff = Double(cellInfo.row - nearestCenter.row)

                // more fluid
                // dy = (diff < 0 ? -1.0 : 1.0) * 10.0 * CGFloat(pow(4.0, abs(diff)))

                if diff < 0 {
                    dy = -50.0
                } else {
                    dy = +50.0
                }

                alpha = 0.5
            }

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                cellInfo.cell.contentView.bounds.size.height = height  // FIXME
                cellInfo.cell.transform = CGAffineTransformMakeTranslation(0, dy)
                cellInfo.cell.alpha = alpha
            })
        }
    }
}
