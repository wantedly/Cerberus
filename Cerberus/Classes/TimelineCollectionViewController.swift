import UIKit
import Timepiece

class TimelineCollectionViewController: UICollectionViewController {
    
    let reuseIdentifier = "TimeCell"
    var timeArray = [String]()
    var notificationCenter = NSNotificationCenter.defaultCenter()
    let scrollNotificationLabel = "scrolled"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for (var date = NSDate().beginningOfDay; date < NSDate().endOfDay; date = date + 30.minutes) {
            timeArray.append(date.stringFromFormat("HH:mm"))
        }
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
        notificationCenter.postNotificationName(scrollNotificationLabel, object: scrollView)
    }
}
