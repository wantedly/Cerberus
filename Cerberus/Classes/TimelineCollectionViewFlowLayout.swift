import UIKit

class TimelineCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func awakeFromNib() {
        super.awakeFromNib()

        sectionInset = UIEdgeInsetsMake(16, 0, 16, 0)
    }
}
