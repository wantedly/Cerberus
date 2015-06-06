import UIKit
import Async
import Timepiece

class EventsCollectionViewController: UICollectionViewController {

    let reuseIdentifier = "EventCell"
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

        self.collectionView?.registerNib(UINib(nibName: "EventCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsetsMake(50, 0, 0, 0)
        syncScroller = SyncScroller.get()
        syncScroller.register(collectionView!)
    }

    override func viewWillDisappear(animated: Bool) {
        syncScroller.unregister(collectionView!)
        super.viewWillDisappear(animated)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendar.events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.eventModel = self.calendar.events[indexPath.row]
        if indexPath.row == 0 {
            cell.topOffsetConstraint.constant = 0
            cell.bottomOffsetConstraint.constant = 8
        } else if indexPath.row == self.calendar.events.count - 1 {
            cell.bottomOffsetConstraint.constant = 0
            cell.topOffsetConstraint.constant = 8
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let minuteHeight: CGFloat = 100.0 / 30

        let event = self.calendar.events[indexPath.row]
        var end = event.endDate.hour * 60 + event.endDate.minute
        
        if end == 0 {
            end = 24 * 60
        }

        let start = event.startDate.hour * 60 + event.startDate.minute
        let span = end - start
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = minuteHeight * CGFloat(span)

        return CGSizeMake(width, height)
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        syncScroller.scroll(scrollView)
    }
}
