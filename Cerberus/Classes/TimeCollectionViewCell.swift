import UIKit

class TimeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func makeLabelBold() {
        self.timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 80.0)
    }

    func makeLabelNormal() {
        self.timeLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 80.0)
    }
}
