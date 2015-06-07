import UIKit
import EventKit
import Async
import Timepiece

class EventsCollectionViewController: UICollectionViewController {

    var syncScroller: SyncScroller!
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

        syncScroller = SyncScroller.get()
        syncScroller.register(collectionView!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventStoreChanged:", name: EKEventStoreChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChooseCalendarNotification:", name: NotifictionNames.MainViewControllerDidChooseCalendarNotification.rawValue, object: nil)

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        syncScroller.unregister(collectionView!)
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
        syncScroller.scroll(scrollView)
    }
}
