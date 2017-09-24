import UIKit

class TimeCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    var time: Time? {
        didSet {
            updateLabels()
            updateStyleIfNeeded()
        }
    }
    private var isCurrent: Bool?

    private func updateLabels() {
        guard let time = time else {
            return
        }
        titleLabel.text = String(format: "%02d:%02d", time.hour, time.minute)
    }

    func updateStyleIfNeeded() {
        guard let isCurrent = time?.isCurrent, isCurrent != self.isCurrent else {
            return
        }
        titleLabel.alpha = isCurrent ? 1 : 0.4
        self.isCurrent = isCurrent
    }
}
