import UIKit
import Async

class EventsCollectionViewController: UICollectionViewController {

    var calendar: Calendar!
    let reuseIdentifier = "EventCell"

    override func viewDidLoad() {
        self.calendar = Calendar()

        self.calendar.authorize { status in
            switch status {
            case .Error:
                Async.background {
                    let alert = UIAlertController(
                        title: "許可されませんでした",
                        message: "Privacy->App->Reminderで変更してください",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )

                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }

            case .Success:
                println("Authorized")
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.calendar.todaysEvents(NSDate()).count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = CollectionViewCellreuseIdentifier.EventCell.rawValue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.titleLabel.text = self.calendar.todaysEvents(NSDate())[indexPath.row].title
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let minuteHeight: CGFloat = 2;

        let event = self.calendar.todaysEvents(NSDate())[indexPath.row]
        let span = event.endDate.hour * 60 + event.endDate.minute -
            (event.startDate.hour * 60 + event.startDate.minute)
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = minuteHeight * CGFloat(span)

        return CGSizeMake(width, height)
    }
}