import UIKit
import Async

class EventsCollectionViewController: UICollectionViewController {

    var calendar: Calendar!

    var arr: [[Int]] = [[8*60, 9*60], [11*60+30, 13*60]]

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
        return self.calendar.events.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = CollectionViewCellreuseIdentifier.EventCell.rawValue
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventCollectionViewCell
        cell.titleLabel.text = self.calendar.events[indexPath.row].title
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let minuteHeight: CGFloat = 2;
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = minuteHeight * CGFloat(createCalendarArray(arr)[indexPath.item])

        return CGSizeMake(width, height)
    }

    func createCalendarArray(array: [[Int]]) -> [Int] {
        var calendarArr: [Int] = []
        var cur = 0;
        for start_end in array {
            let start = start_end[0], end = start_end[1]
            if cur < start {
                calendarArr.append(start - cur)
            }
            calendarArr.append(end - start)
            cur = end
        }
        if cur < 24 * 60 {
            calendarArr.append(24 * 60 - cur)
        }
        return calendarArr
    }
}