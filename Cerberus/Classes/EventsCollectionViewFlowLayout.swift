import UIKit

class EventsCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()

        minimumLineSpacing = EventInterval
        minimumInteritemSpacing = EventInterval
        sectionInset = UIEdgeInsetsMake(WrapperTop, 0, WrapperBottom, 0)
    }

    func sizeForEvent(event: Event) -> CGSize {
        let span = CGFloat(event.span())
        // let span = CGFloat(min(max(30, event.span()), 5 * 30))  // TODO

        let width = collectionView!.bounds.width
        let height = (TimelineHeight / 30) * span - EventInterval

        return CGSizeMake(width, height)
    }
}
