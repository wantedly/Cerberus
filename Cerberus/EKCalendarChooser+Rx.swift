import EventKitUI
import RxSwift
import RxCocoa

class RxEKCalendarChooserDelegateProxy : DelegateProxy, EKCalendarChooserDelegate, DelegateProxyType {
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let calendarChooser: EKCalendarChooser = object as! EKCalendarChooser
        return calendarChooser.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let calendarChooser: EKCalendarChooser = object as! EKCalendarChooser
        calendarChooser.delegate = delegate as? EKCalendarChooserDelegate
    }
}

extension Reactive where Base: EKCalendarChooser {
    
    var delegate: DelegateProxy {
        return RxEKCalendarChooserDelegateProxy.proxyForObject(base)
    }
    
    var selectionDidChange: Observable<Void> {
        return delegate
            .methodInvoked(#selector(EKCalendarChooserDelegate.calendarChooserSelectionDidChange(_:)))
            .map { _ in }
    }
    
    var didFinish: Observable<Void> {
        return delegate
            .methodInvoked(#selector(EKCalendarChooserDelegate.calendarChooserDidFinish(_:)))
            .map { _ in }
    }
    
    var didCancel: Observable<Void> {
        return delegate
            .methodInvoked(#selector(EKCalendarChooserDelegate.calendarChooserDidCancel(_:)))
            .map { _ in }
    }
    
    func present(in parent: UIViewController?) -> Observable<EKCalendarChooser> {
        return Observable.create { [weak parent] observer in
            let calendarChooser = self.base
            let navigationController = UINavigationController(rootViewController: calendarChooser)

            let dismissDisposable = Observable
                .merge(
                    calendarChooser.rx.didFinish,
                    calendarChooser.rx.didCancel
                )
                .subscribe(onNext: { [weak navigationController] in
                    guard let navigationController = navigationController else {
                        return
                    }
                    dismissViewController(navigationController, animated: true)
                })
            
            guard let parent = parent else {
                return Disposables.create()
            }
            
            parent.present(navigationController, animated: true)
            observer.onNext(calendarChooser)
            
            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(navigationController, animated: true)
            })
        }
    }
}

private func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
    
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated)
    }
}
