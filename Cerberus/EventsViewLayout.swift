import UIKit

class EventsViewLayout: UICollectionViewLayout {
    
    struct Metric {
        static let interitemSpacing: CGFloat = 10
        static let contentInsets = UIEdgeInsets(top: TimesViewLayout.Metric.itemTranslationY, left: 25, bottom: TimesViewLayout.Metric.itemTranslationY, right: 25)
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
                frame.origin.y = EventsViewLayout.y(of: event.startTime) + Metric.interitemSpacing
                frame.size.width = collectionView.bounds.width - Metric.contentInsets.left - Metric.contentInsets.right
                frame.size.height = EventsViewLayout.y(of: event.endTime) - EventsViewLayout.y(of: event.startTime) - Metric.interitemSpacing / 2
                return frame
            }()
            return attributes
        }
    }
    
    static func time(of y: CGFloat) -> Time {
        let distancePerMinute = TimesViewLayout.Metric.sizeForItem.height / CGFloat(Time.strideTime.hour * 60 + Time.strideTime.minute)
        let minutes = Int((y - Metric.contentInsets.top) / distancePerMinute)
        return Time(hour: minutes / 60, minute: minutes % 60)
    }
    
    static func y(of time: Time) -> CGFloat {
        let distancePerMinute = TimesViewLayout.Metric.sizeForItem.height / CGFloat(Time.strideTime.hour * 60 + Time.strideTime.minute)
        let minutes = time.hour * 60 + time.minute
        return distancePerMinute * CGFloat(minutes) + Metric.contentInsets.top
    }
}
