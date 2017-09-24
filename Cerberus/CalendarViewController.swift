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
            .drive(eventsView.rx.items(cellIdentifier: "EventCell", cellType: EventCell.self)) { _, event, cell in
                cell.update(with: event)
            }
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let currentContentOffsetY = max(min(TimesViewLayout.y(of: Time(Date())) - timesView.bounds.height / 2, timesView.contentSize.height), 0)
        timesView.setContentOffset(CGPoint(x: 0, y: currentContentOffsetY), animated: true)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "NavigationBarBackground"), for: .default)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 28)]
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
        if scrollView == timesView {
            eventsView.contentOffset = scrollView.contentOffset
        }
    }
}
