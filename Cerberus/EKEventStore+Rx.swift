import EventKit
import RxSwift
import RxCocoa

extension Reactive where Base: EKEventStore {

    func requestAccess(to entityType: EKEntityType) -> Observable<Bool> {
        return Observable.create { observer in
            self.base.requestAccess(to: entityType) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        observer.on(.error(error))
                    } else {
                        observer.on(.next(granted))
                    }
                    observer.on(.completed)
                }
            }
            return Disposables.create()
        }
    }
}
