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
        collectionView?.contentOffset = timelineView.contentOffset
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
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
