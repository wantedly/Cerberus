import UIKit

class SyncScroller {

    static let sharedScroller = SyncScroller()

    private var views: Array<UIScrollView>

    private init() {
        self.views = []
    }

    static func get() -> SyncScroller {
        return sharedScroller
    }

    func register(scrollView: UIScrollView) {
        self.views.append(scrollView)
    }

    func unregister(scrollView: UIScrollView) {
        if let index = find(views, scrollView) {
            views.removeAtIndex(index)
        }
    }

    func scroll(scrollView: UIScrollView) {
        if scrollView.dragging || scrollView.bounces {
            for view in self.views {
                if !view.isEqual(scrollView) {
                    view.contentOffset.y = scrollView.contentOffset.y
                }
            }
        }

    }
}
