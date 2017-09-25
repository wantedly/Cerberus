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
            case (.empty, .past):
                return base(for: event).withAlphaComponent(0.3)
            case (.empty, .future):
                return base(for: event).withAlphaComponent(0.7)
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

    struct Metric {
        static func borderWidth(for event: Event) -> CGFloat {
            return event.position == .current ? 1 : 0.5
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!

    var event: Event? {
        didSet {
            eventPosition = event?.position
            updateLabels()
            updateStyle()
        }
    }
    private var eventPosition: EventPosition?

    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 3
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.isHidden = titleLabel.frame.maxY > bounds.height
        timeRangeLabel.isHidden = timeRangeLabel.frame.maxY > bounds.height
    }

    func updateStyleIfNeeded() {
        if let event = event, event.position != self.eventPosition {
            self.eventPosition = event.position
            updateStyle()
        }
    }

    private func updateLabels() {
        guard let event = event else {
            return
        }
        switch event.type {
        case let .normal(title):
            titleLabel.text = title
            timeRangeLabel.text = String(format: "%02d:%02d-%02d:%02d", event.startTime.hour, event.startTime.minute, event.endTime.hour, event.endTime.minute)
        case .empty:
            titleLabel.text = "Available"
            timeRangeLabel.text = nil
        }
    }

    private func updateStyle() {
        guard let event = event else {
            return
        }
        titleLabel.textColor = Color.title(for: event)
        timeRangeLabel.textColor = Color.timeRange(for: event)
        backgroundColor = Color.background(for: event)
        layer.borderColor = Color.border(for: event).cgColor
        layer.borderWidth = Metric.borderWidth(for: event)
    }
}
