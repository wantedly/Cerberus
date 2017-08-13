import UIKit
import RxSwift

@testable import Cerberus

class MockWireframe: WireframeType {
    weak var rootViewController: UIViewController? { return UIViewController() }

    var promptClosure: (_ error: Error) -> Observable<Void> = { _ in return .empty() }
    func prompt(for error: Error) -> Observable<Void> { return promptClosure(error) }
}
