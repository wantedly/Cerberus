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
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            let calendarChooser = self.base
            let navigationController = UINavigationController(rootViewController: calendarChooser)

            let dismissDisposable = Observable
                .merge(
                    calendarChooser.rx.didFinish,
                    calendarChooser.rx.didCancel
                )
                .subscribe(onNext: {
                    navigationController.dismiss(animated: true) {
                        observer.on(.completed)
                    }
                })
            
            parent.present(navigationController, animated: true)
            observer.on(.next(calendarChooser))
            
            return dismissDisposable
        }
    }
}
