import UIKit

class EventsCollectionViewController: UICollectionViewController {

    let reuseIdentifier = "EventCell"
    let syncScroller = SyncScroller.get()

    override func viewDidLoad() {
        super.viewDidLoad();

        syncScroller.register(collectionView!)
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
        syncScroller.scroll(scrollView)
    }
}
