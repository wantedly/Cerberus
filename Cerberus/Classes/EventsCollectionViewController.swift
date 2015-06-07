import UIKit
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

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = 16.0
        flowLayout.minimumInteritemSpacing = 16.0

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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellreuseIdentifier.EventCell.rawValue, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.eventModel = self.calendar.events[indexPath.row]
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
        var span = end - start

        if span < 30 {
            span = 30
        } else if span > 5 * 30 {
            span = 5 * 30
        }

        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = minuteHeight * CGFloat(span)

        return CGSizeMake(width, height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewFlowLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 200, height: 50)
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        syncScroller.scroll(scrollView)
    }
}
