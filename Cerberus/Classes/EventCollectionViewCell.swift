import UIKit
import Timepiece

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var wrapView: UIView!

    var eventModel: Event? {
        didSet { update() }
    }

    func update() {
        if let event = eventModel {
            let time = join(" - ", [event.startDate, event.endDate].map { $0.stringFromFormat("HH:mm") })

            self.titleLabel.text = event.title
            self.timeLabel.text  = time
        }
        wrapView.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3).CGColor
    }
}
