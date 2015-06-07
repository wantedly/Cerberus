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

        let width: CGFloat = collectionView!.bounds.width
        let height: CGFloat = minuteHeight * CGFloat(event.span()) - EventInterval

        return CGSizeMake(width, height)
    }
}
