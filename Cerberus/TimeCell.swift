import UIKit

class TimeCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    func update(with time: Time) {
        titleLabel.text = String(format: "%02d:%02d", time.hour, time.minute)
    }
}
