import UIKit
import Timepiece

class TimelineCollectionViewController: UICollectionViewController {
    
    let reuseIdentifier = "TimeCell"
    var timeArray = [String]()
    var notificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        super.viewDidLoad()

        for (var date = NSDate().beginningOfDay; date < NSDate().endOfDay; date = date + 30.minutes) {
            timeArray.append(date.stringFromFormat("HH:mm"))
        }
        notificationCenter.addObserver(self, selector: "receiveScrollNotification:", name: "scrolled", object: nil)
    }

    func receiveScrollNotification(notification: NSNotification) {
        let eventView = notification.object as! UIScrollView
        collectionView?.contentOffset = eventView.contentOffset
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TimeCollectionViewCell
        cell.timeLabel.text = timeArray[indexPath.row]
        return cell
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.isEqual(self)) {
            return
        }
        if scrollView.dragging {
            notificationCenter.postNotificationName("scrolled", object: scrollView)
        }
    }
}
