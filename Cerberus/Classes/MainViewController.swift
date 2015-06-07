import UIKit

class MainViewController: UIViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navCtrl = self.navigationController {
            let bgImage = UIImage(named: "background")
            navCtrl.navigationBar.setBackgroundImage(bgImage, forBarMetrics: UIBarMetrics.Default)
        }
        setNavbarTitle()
    }

    func setNavbarTitle(date: NSDate = NSDate()) {
        let title = date.stringFromFormat("EEEE, MMMM d, yyyy")
        self.title = title
    }

}