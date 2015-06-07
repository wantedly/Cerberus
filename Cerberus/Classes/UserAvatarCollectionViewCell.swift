import UIKit

class UserAvatarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!

    var userModel: User? {
        didSet { update() }
    }

    private func update() {
        if let user = userModel, avatarUrl = user.avatarUrl() {
            avatarImageView.sd_setImageWithURL(avatarUrl)
        }
    }
}
