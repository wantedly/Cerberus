import UIKit
import RxSwift
import RxCocoa

protocol WireframeType {
    weak var rootViewController: UIViewController? { get }

    @discardableResult
    func prompt(for error: Error) -> Observable<Void>
}

class Wireframe: WireframeType {

    weak var rootViewController: UIViewController?

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }

    func prompt(for error: Error) -> Observable<Void> {
        return Observable.create { observer in
            let alertView = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                observer.on(.next(Void()))
            })

            self.rootViewController?.present(alertView, animated: true)

            return Disposables.create {
                alertView.dismiss(animated:false)
            }
        }
    }
}
