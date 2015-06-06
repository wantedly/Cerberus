import UIKit

class SyncScrollCollectionViewController : UICollectionViewController {
    var notificationCenter = NSNotificationCenter.defaultCenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(self, selector: "receiveScrollNotification:", name: "scrolled", object: nil)
    }

    func receiveScrollNotification(notification: NSNotification) {
        let scrolledView = notification.object as! UIScrollView
        let offset = scrolledView.contentOffset
        collectionView?.contentOffset.y = offset.y
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
