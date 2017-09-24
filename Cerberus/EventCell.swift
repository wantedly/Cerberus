import UIKit

class EventCell: UICollectionViewCell {

    struct Color {
        private static func base(for event: Event) -> UIColor {
            switch event.type {
            case .normal:
                return UIColor.white
            case .empty:
                return UIColor(red: 108/255.0, green: 198/255.0, blue: 68/255.0, alpha: 1)
            }
        }

        static func title(for event: Event) -> UIColor {
            switch (event.type, event.position) {
            case (.normal, .past):
                return base(for: event).withAlphaComponent(0.15)
            case (.normal, .future):
                return base(for: event).withAlphaComponent(0.6)
            default:
                return base(for: event).withAlphaComponent(1)
            }
        }

        static func timeRange(for event: Event) -> UIColor {
            switch (event.type, event.position) {
            case (.normal, .past):
                return base(for: event).withAlphaComponent(0.15)
            case (.normal, .future), (.normal, .current):
                return base(for: event).withAlphaComponent(0.6)
            default:
                return UIColor.clear
            }
        }

        static func background(for event: Event) -> UIColor {
            switch (event.type, event.position) {
            case (.normal, .past), (.normal, .future):
                return UIColor.black.withAlphaComponent(0.1)
            case (.normal, .current):
                return UIColor.black.withAlphaComponent(0.3)
            case (.empty, .past), (.empty, .future):
                return base(for: event).withAlphaComponent(0.1)
            case (.empty, .current):
                return base(for: event).withAlphaComponent(0.3)
            }
        }

        static func border(for event: Event) -> UIColor {
            switch (event.type, event.position) {
            case (.normal, .past), (.normal, .future):
                return base(for: event).withAlphaComponent(0.3)
            case (.normal, .current):
                return base(for: event).withAlphaComponent(1)
            case (.empty, .past), (.empty, .future):
                return base(for: event).withAlphaComponent(0.7)
            case (.empty, .current):
                return base(for: event).withAlphaComponent(1)
            }
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.borderWidth = 0.5
        layer.cornerRadius = 3
    }

    func update(with event: Event) {
        switch event.type {
        case let .normal(title):
            titleLabel.text = title
            timeRangeLabel.text = String(format: "%02d:%02d-%02d:%02d", event.startTime.hour, event.startTime.minute, event.endTime.hour, event.endTime.minute)
        case .empty:
            titleLabel.text = "Available"
            timeRangeLabel.text = nil
        }

        titleLabel.textColor = Color.title(for: event)
        timeRangeLabel.textColor = Color.timeRange(for: event)
        backgroundColor = Color.background(for: event)
        layer.borderColor = Color.border(for: event).cgColor
    }
}
