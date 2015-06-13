import UIKit
import Timepiece

class TimelineCollectionViewController: UICollectionViewController {

    var timeArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        for (var date = NSDate().beginningOfDay; date < NSDate().endOfDay; date = date + 30.minutes) {
            timeArray.append(date.stringFromFormat("HH:mm"))
        }
        timeArray.append("24:00")
        collectionView?.showsVerticalScrollIndicator = false

        let nib = UINib(nibName: XibNames.TimeCollectionViewCell.rawValue, bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: CollectionViewCellreuseIdentifier.TimeCell.rawValue)
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


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let timelineCollectionViewFlowLayout = collectionViewLayout as! TimelineCollectionViewFlowLayout

        return timelineCollectionViewFlowLayout.sizeForTimeline()
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
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let (visibles, nearestCenter) = getVisibleCellsAndNearestCenterCell()

        let timelineCollectionViewFlowLayout = self.collectionViewLayout as! TimelineCollectionViewFlowLayout

        for cellInfo in visibles {
            let cell = cellInfo.cell as! TimeCollectionViewCell

            cell.hidden = false

            let time = self.timeArray[cellInfo.row]

            var dy: CGFloat     = 0.0
            var height: CGFloat = timelineCollectionViewFlowLayout.sizeForTimeline().height
            var alpha: CGFloat  = 0.0

            if cell == nearestCenter.cell {
                height += 100
                alpha = 1.0
                cell.makeLabelBold()
            } else {
                if cellInfo.row < nearestCenter.row {
                    dy = -50.0
                } else {
                    dy = +50.0
                }

                alpha = 0.5
                cell.makeLabelNormal()
            }

            UIView.animateWithDuration(0.6,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.0,
                options: .CurveEaseInOut,
                animations: { () -> Void in
                    cell.bounds.size.height = height
                    cell.transform = CGAffineTransformMakeTranslation(0, dy)
                    cell.alpha = alpha
                },
                completion: nil
            )
        }
    }

}
