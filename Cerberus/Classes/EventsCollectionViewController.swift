import UIKit

class EventsCollectionViewController: UICollectionViewController {
    
    var calendar: Calendar!
    
    let reuseIdentifier = "EventCell"

    override func viewDidLoad() {
        self.calendar = Calendar()
        self.calendar.authorize()
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendar.events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.titleLabel.text = self.calendar.events[indexPath.row].title
        return cell
    }
}