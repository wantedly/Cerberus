import UIKit

class TimelineCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()

        sectionInset = UIEdgeInsetsMake(WrapperTop, 0, WrapperBottom, 0)
    }

    func sizeForTimeline() -> CGSize {
        return CGSizeMake(collectionView!.bounds.width, TimelineHeight)
    }
}
