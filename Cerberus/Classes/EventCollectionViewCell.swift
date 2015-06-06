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

            if event.available {
                self.timeLabel.text = nil
                self.wrapperView.backgroundColor = UIColor(red: 108/255.0, green: 198/255.0, blue: 68/255.0, alpha: 0.1)
                self.wrapperView.layer.borderColor = UIColor(red: 108/255.0, green: 198/255.0, blue: 68/255.0, alpha: 0.7).CGColor
                self.titleLabel.textColor = UIColor(red: 108/255.0, green: 198/255.0, blue: 68/255.0, alpha: 1.0)
            } else {
                self.timeLabel.text = time
                wrapperView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).CGColor
            }
        }
    }
}
