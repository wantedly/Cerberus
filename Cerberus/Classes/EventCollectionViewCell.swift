import UIKit
import Timepiece

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var topOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomOffsetConstraint: NSLayoutConstraint!

    var eventModel: Event? {
        didSet { update() }
    }

    func update() {
        if let event = eventModel {
            let time = join(" - ", [event.startDate, event.endDate].map { $0.stringFromFormat("HH:mm") })
            let attendees = join(", ", event.attendees.map { $0.name })

            self.titleLabel.text = event.title
            self.timeLabel.text  = time
        }
        wrapperView.layer.borderColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3).CGColor
    }
}
