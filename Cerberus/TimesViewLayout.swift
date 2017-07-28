import UIKit

class TimesViewLayout: UICollectionViewLayout {

    struct Metric {
        static let sizeForItem = CGSize(width: 200, height: 100)
        static let itemTranslationY = sizeForItem.height / 2
        static let contentHeight: CGFloat = sizeForItem.height * CGFloat(Time.timesOfDay.count) + itemTranslationY * 2
        static let contentInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
    }

    var centerIndexPath: IndexPath?

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        var size = collectionView.bounds.size
        size.height = Metric.contentHeight
        return size
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = {
            var frame: CGRect = .zero
            frame.origin.x = Metric.contentInsets.left
            frame.origin.y = Metric.itemTranslationY + Metric.sizeForItem.height * CGFloat(indexPath.row)
            frame.size = Metric.sizeForItem
            return frame
        }()
        if let centerIndexPath = centerIndexPath {
            if centerIndexPath == indexPath {
                attributes.transform = .identity
            } else {
                attributes.transform.ty = centerIndexPath.row > indexPath.row ? -Metric.itemTranslationY : Metric.itemTranslationY
            }
        }
        return attributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let start = max(Int(rect.minY / Metric.sizeForItem.height), 0)
        let last = min(Int(rect.maxY / Metric.sizeForItem.height), Time.timesOfDay.count - 1)
        guard start < last else {
            return nil
        }
        return (start...last).flatMap { self.layoutAttributesForItem(at: IndexPath(item: $0, section: 0)) }
    }
}
