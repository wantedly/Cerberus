import UIKit

class TimesViewLayout: UICollectionViewLayout {

    struct Metric {
        static let sizeForItem = CGSize(width: 280, height: 200)
        static let contentHeight: CGFloat = sizeForItem.height * CGFloat(Time.timesOfDay.count)
    }

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
            frame.origin.y = Metric.sizeForItem.height * CGFloat(indexPath.row)
            frame.size = Metric.sizeForItem
            return frame
        }()
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

    static func y(of time: Time) -> CGFloat {
        let distancePerMinute = TimesViewLayout.Metric.sizeForItem.height / CGFloat(Time.strideTime.hour * 60 + Time.strideTime.minute)
        let minutes = time.hour * 60 + time.minute
        return TimesViewLayout.Metric.sizeForItem.height / 2 + distancePerMinute * CGFloat(minutes)
    }
}
