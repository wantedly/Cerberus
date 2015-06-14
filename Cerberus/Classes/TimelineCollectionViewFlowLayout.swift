import UIKit

class TimelineCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()

        sectionInset = UIEdgeInsetsMake(WrapperTop + TimelineHeight / 2, 0, WrapperBottom + TimelineHeight / 2, 0)
    }

    func sizeForTimeline() -> CGSize {
        return CGSizeMake(collectionView!.bounds.width, TimelineHeight)
    }
}
