import UIKit
import Timepiece

class TimelineCollectionViewController: UICollectionViewController {
    
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
        let offset = eventView.contentOffset
        collectionView?.contentOffset.y = offset.y
    }

    override func viewDidAppear(animated: Bool) {
        let date = NSDate()
        let newIndex = NSIndexPath(forItem: (date.hour * 60 + date.minute) / 30, inSection: 0)
        self.collectionView?.scrollToItemAtIndexPath(newIndex, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = CollectionViewCellreuseIdentifier.TimeCell.rawValue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TimeCollectionViewCell
        cell.timeLabel.text = timeArray[indexPath.row]
        return cell
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isEqual(self) {
            return
        }
        if scrollView.dragging || scrollView.bounces {
            notificationCenter.postNotificationName("scrolled", object: scrollView)
        }
    }

}
