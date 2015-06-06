import UIKit

class EventsCollectionViewController: UICollectionViewController {

    var calendar: Calendar!
    
    let reuseIdentifier = "EventCell"

    override func viewDidLoad() {
        self.calendar = Calendar()
        self.calendar.authorize { status in
            switch status {
                case .Error:
                    dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                        let alert = UIAlertController(
                            title: "許可されませんでした",
                            message: "Privacy->App->Reminderで変更してください",
                            preferredStyle: UIAlertControllerStyle.Alert
                        )

                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

                        alert.addAction(okAction)
                        self?.presentViewController(alert, animated: true, completion: nil)
                    })

                case .Success:
                    println("Authorized")
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendar.events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = CollectionViewCellreuseIdentifier.EventCell.rawValue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.titleLabel.text = self.calendar.events[indexPath.row].title
        return cell
    }
}