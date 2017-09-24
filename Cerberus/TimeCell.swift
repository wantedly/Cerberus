import UIKit

class TimeCell: UICollectionViewCell {

    struct Font {
        static let currentTitle = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .medium)
        static let title = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .ultraLight)
    }

    @IBOutlet weak var titleLabel: UILabel!

    var time: Time? {
        didSet {
            isCurrent = time?.isCurrent
            updateLabels()
            updateStyle()
        }
    }
    private var isCurrent: Bool?

    func updateStyleIfNeeded() {
        if let isCurrent = time?.isCurrent, isCurrent != self.isCurrent {
            self.isCurrent = isCurrent
            updateStyle()
        }
    }

    private func updateLabels() {
        guard let time = time else {
            return
        }
        titleLabel.text = String(format: "%02d:%02d", time.hour, time.minute)
    }

    private func updateStyle() {
        guard let time = time else {
            return
        }
        titleLabel.alpha = time.isCurrent ? 1 : 0.4
        titleLabel.font = time.isCurrent ? Font.currentTitle : Font.title
    }
}
