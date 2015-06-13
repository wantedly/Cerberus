import UIKit
import Timepiece

class TimelineCollectionViewController: UICollectionViewController {

    var timeArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        generateTimeLabels()

        collectionView?.showsVerticalScrollIndicator = false

        let nib = UINib(nibName: XibNames.TimeCollectionViewCell.rawValue, bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: CollectionViewCellreuseIdentifier.TimeCell.rawValue)
    }

    private func generateTimeLabels() {
        for (var date = NSDate().beginningOfDay; date < NSDate().endOfDay; date = date + 30.minutes) {
            timeArray.append(date.stringFromFormat("HH:mm"))
        }

        timeArray.append("24:00")
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
}
