import UIKit

class TimelineCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()

        sectionInset = UIEdgeInsetsMake(WrapperTop, 0, WrapperBottom, 0)
    }
}
