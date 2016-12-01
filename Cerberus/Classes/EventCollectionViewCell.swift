import UIKit
import Timepiece

class EventCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var userAvatarsCollectionView: UICollectionView!

    var eventModel: Event? {
        didSet { update() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.wrapperView.layer.cornerRadius = 3
        self.wrapperView.layer.borderWidth = 1

        let nib = UINib(nibName: XibNames.UserAvatarCollectionViewCell.rawValue, bundle: nil)
        self.userAvatarsCollectionView.registerNib(nib, forCellWithReuseIdentifier: CollectionViewCellreuseIdentifier.UserAvatarCell.rawValue)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layoutIfNeeded()
        titleLabel.hidden = titleLabel.bounds.height < 20
        timeLabel.hidden = timeLabel.bounds.height < 16
        userAvatarsCollectionView.hidden = userAvatarsCollectionView.bounds.height < 40

    }

    private func update() {
        if let event = eventModel {
            self.titleLabel.text = event.title

            if event.isAvailable() {
                self.timeLabel.text = nil

                self.wrapperView.backgroundColor = UIColor(hex: 0x6cc644, alpha: 0.1)
                self.wrapperView.layer.borderColor = UIColor(hex: 0x6cc644, alpha: 0.7).CGColor
                self.titleLabel.textColor = UIColor(hex: 0x6cc644, alpha: 1.0)
            } else {
                let time = [event.startDate, event.endDate].map { $0.stringFromFormat("HH:mm") }
                self.timeLabel.text = time.joinWithSeparator(" - ")

                self.wrapperView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.1)
                self.wrapperView.layer.borderColor = UIColor(hex: 0xffffff, alpha: 0.3).CGColor
                self.titleLabel.textColor = UIColor(hex: 0xffffff, alpha: 1.0)
            }
        }

        self.userAvatarsCollectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eventModel?.attendees.count ?? 0
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellreuseIdentifier.UserAvatarCell.rawValue, forIndexPath: indexPath) as! UserAvatarCollectionViewCell
        cell.userModel = self.eventModel?.attendees[indexPath.row]
        return cell
    }
}
