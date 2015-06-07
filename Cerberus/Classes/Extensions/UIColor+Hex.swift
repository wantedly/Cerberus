import UIKit

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xff) / 255.0
        let g = CGFloat((hex >> 8 ) & 0xff) / 255.0
        let b = CGFloat((hex >> 0 ) & 0xff) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}