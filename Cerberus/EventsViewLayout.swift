import UIKit

class EventsViewLayout: UICollectionViewLayout {

    struct Metric {
        static let interitemSpacing: CGFloat = 10
        static let contentInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    }

    private var layoutAttributes = [UICollectionViewLayoutAttributes]()

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        var size = collectionView.bounds.size
        size.height = TimesViewLayout.Metric.contentHeight
        return size
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes
    }

    func updateLayoutAttributes(with events: [Event]) {
        guard let collectionView = collectionView else {
            return
        }

        layoutAttributes = events.enumerated().map { index, event in
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            attributes.frame = {
                var frame: CGRect = .zero
                frame.origin.x = Metric.contentInsets.left
                frame.origin.y = TimesViewLayout.y(of: event.startTime) + Metric.contentInsets.top
                frame.size.width = collectionView.bounds.width - Metric.contentInsets.left - Metric.contentInsets.right
                frame.size.height = TimesViewLayout.y(of: event.endTime) - TimesViewLayout.y(of: event.startTime) - Metric.interitemSpacing
                return frame
            }()
            return attributes
        }
    }
}
