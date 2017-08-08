import UIKit
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarsButtonItem: UIBarButtonItem!
    @IBOutlet weak var timesView: UICollectionView!
    @IBOutlet weak var timesViewLayout: TimesViewLayout!
    @IBOutlet weak var eventsView: UICollectionView!
    @IBOutlet weak var eventsViewLayout: EventsViewLayout!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupGestureRecognizer()
        updateDateOfTitle()

        let viewModel = CalendarViewModel(calendarService: CalendarService(), wireframe: Wireframe(rootViewController: self))

        calendarsButtonItem.rx.tap
            .bind(to: viewModel.calendarsButtonItemDidTap)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.UIApplicationDidBecomeActive)
            .map { _ in }
            .bind(to: viewModel.applicationDidBecomeActive)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.UIApplicationSignificantTimeChange)
            .map { _ in }
            .do(onNext: {[weak self] in
                self?.updateDateOfTitle()
            })
            .bind(to: viewModel.applicationSignificantTimeChange)
            .disposed(by: disposeBag)

        viewModel.events
            .do(onNext: { [weak self] events in
                self?.eventsViewLayout.updateLayoutAttributes(with: events)
            })
            .bind(to: eventsView.rx.items(cellIdentifier: "EventCell", cellType: EventCell.self)) { _, event, cell in
                cell.update(with: event)
            }
            .disposed(by: disposeBag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        invalidateTimesViewLayoutIfNeeded(animated: false)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "NavigationBarBackground"), for: .default)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 28)]
    }

    private func setupGestureRecognizer() {
        view.addGestureRecognizer(timesView.panGestureRecognizer)
        eventsView.isScrollEnabled = false
    }

    private func updateDateOfTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        navigationItem.title = dateFormatter.string(from: Date())
    }
}

extension CalendarViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        eventsView.contentOffset = scrollView.contentOffset
        invalidateTimesViewLayoutIfNeeded(animated: true)
    }

    func invalidateTimesViewLayoutIfNeeded(animated: Bool) {
        let indexPaths = timesView.indexPathsForVisibleItems.sorted()
        if indexPaths.isEmpty {
            return
        }

        let centerIndexPath = indexPaths[indexPaths.count / 2]
        if timesViewLayout.centerIndexPath != centerIndexPath {
            timesViewLayout.centerIndexPath = centerIndexPath

            let actions = {
                self.timesViewLayout.invalidateLayout()
            }

            if animated {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, animations: actions)
            } else {
                actions()
            }
        }
    }
}
