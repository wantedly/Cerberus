import UIKit

class EventCell: UICollectionViewCell {

    struct Color {
        static let green = UIColor(colorLiteralRed: 108/255.0, green: 198/255.0, blue: 68/255.0, alpha: 1)
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
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            timeRangeLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            backgroundColor = UIColor.black.withAlphaComponent(0.1)
            layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        case .empty:
            titleLabel.text = "Available"
            timeRangeLabel.text = nil
            titleLabel.textColor = Color.green
            timeRangeLabel.textColor = Color.green
            backgroundColor = Color.green.withAlphaComponent(0.1)
            layer.borderColor = Color.green.withAlphaComponent(0.7).cgColor
        }
    }
}
