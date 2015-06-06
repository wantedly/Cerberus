import UIKit
import Timepiece

class TimelineCollectionViewController: UICollectionViewController {

    var timeArray = [String]()
    let syncScroller = SyncScroller.get()

    override func viewDidLoad() {
        super.viewDidLoad()

        for (var date = NSDate().beginningOfDay; date < NSDate().endOfDay; date = date + 30.minutes) {
            timeArray.append(date.stringFromFormat("HH:mm"))
        }
        syncScroller.register(collectionView!)
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
        syncScroller.scroll(scrollView)
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollToCenteredCell()
    }

    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollToCenteredCell()
        }
    }

    // MARK: Private

    private func scrollToCenteredCell() {
        let point = CGPointMake(collectionView!.center.x, collectionView!.center.y + collectionView!.contentOffset.y)
        if let centeredIndexPath = collectionView?.indexPathForItemAtPoint(point) {
            collectionView?.scrollToItemAtIndexPath(centeredIndexPath, atScrollPosition: .CenteredVertically, animated: true)
        }
    }
}
