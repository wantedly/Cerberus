import UIKit
import Timepiece

class TimelineCollectionViewController: UICollectionViewController {

    var timeArray = [String]()
    var syncScroller: SyncScroller!

    override func viewDidLoad() {
        super.viewDidLoad()

        for (var date = NSDate().beginningOfDay; date < NSDate().endOfDay; date = date + 30.minutes) {
            timeArray.append(date.stringFromFormat("HH:mm"))
        }
        timeArray.append("24:00")
        collectionView?.showsVerticalScrollIndicator = false

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsetsMake(16, 0, 16, 0)

        syncScroller = SyncScroller.get()
        syncScroller.register(collectionView!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navCtrl = self.navigationController {
            let bgImage = UIImage(named: "background")
            navCtrl.navigationBar.setBackgroundImage(bgImage, forBarMetrics: UIBarMetrics.Default)
            setNavbarTitle()
        }
    }

    func setNavbarTitle(date: NSDate = NSDate()) {
        let title = date.stringFromFormat("EEEE, MMMM d, yyyy")
        self.navigationController?.navigationBar.topItem?.title = title
    }

    override func viewDidAppear(animated: Bool) {
        let date = NSDate()
        let newIndex = NSIndexPath(forItem: (date.hour * 60 + date.minute) / 30, inSection: 0)
        self.collectionView?.scrollToItemAtIndexPath(newIndex, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
    }

    override func viewWillDisappear(animated: Bool) {
        syncScroller.unregister(collectionView!)
        super.viewWillDisappear(animated)
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
