import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!

    var eventModel: Event? {
        didSet { update() }
    }

    func update() {
        if let event = eventModel {
            self.titleLabel.text = event.title
            self.timeLabel.text  = join(" - ", [event.startDate.stringFromFormat("HH:mm"), event.endDate.stringFromFormat("HH:mm")])
            self.attendeesLabel.text = "aaa"
        }
    }
}
