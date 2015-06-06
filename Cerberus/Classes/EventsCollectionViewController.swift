import UIKit

class EventsCollectionViewController: UICollectionViewController {

    let reuseIdentifier = "EventCell"
    var notificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        super.viewDidLoad();
        // Listen scroll event of TimelineCollectionView
        notificationCenter.addObserver(self, selector: "receiveScrollNotification:", name: "scrolled", object: nil)
    }

    func receiveScrollNotification(notification: NSNotification) {
        let timelineView = notification.object as! UIScrollView
        let offset = timelineView.contentOffset
        collectionView?.contentOffset.y = offset.y
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = CollectionViewCellreuseIdentifier.EventCell.rawValue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
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
