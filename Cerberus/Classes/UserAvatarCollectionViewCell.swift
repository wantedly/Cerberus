import UIKit

class UserAvatarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!

    var userModel: User? {
        didSet { update() }
    }

    private func update() {
        if let user = userModel, avatarUrl = user.avatarUrl() {
            avatarImageView.sd_setImageWithURL(avatarUrl) { [weak self] (image, error, cacheType, url) in
                self?.roundAvatarImageView()
            }
        }
    }

    private func roundAvatarImageView() {
        avatarImageView.layer.cornerRadius = CGRectGetWidth(avatarImageView.bounds) / 2
        avatarImageView.layer.masksToBounds = true
    }
}
