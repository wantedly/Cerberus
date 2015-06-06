import UIKit
import Timepiece

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!

    var eventModel: Event? {
        didSet { update() }
    }

    func update() {
        if let event = eventModel {
            let time = join(" - ", [event.startDate, event.endDate].map { $0.stringFromFormat("HH:mm") })

            self.titleLabel.text = event.title
            self.timeLabel.text  = time
            self.attendeesLabel.text = "aaa"
        }
    }
}
