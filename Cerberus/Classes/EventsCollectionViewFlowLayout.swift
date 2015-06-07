import UIKit

class EventsCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()

        minimumLineSpacing = EventInterval
        minimumInteritemSpacing = EventInterval
        sectionInset = UIEdgeInsetsMake(WrapperTop + TimelineHeight / 2 + EventPadding, 0, WrapperBottom, 0)
    }

    func sizeForEvent(event: Event) -> CGSize {
        let minuteHeight: CGFloat = TimelineHeight / 30

        var end = event.endDate.hour * 60 + event.endDate.minute

        if end == 0 {
            end = 24 * 60
        }

        let start = event.startDate.hour * 60 + event.startDate.minute
        var span = end - start

        /*
        if span < 30 {
            span = 30
        } else if span > 5 * 30 {
            span = 5 * 30
        }
        */

        let width: CGFloat = collectionView!.bounds.width
        let height: CGFloat = minuteHeight * CGFloat(span) - EventPadding

        return CGSizeMake(width, height)
    }
}
