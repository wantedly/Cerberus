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

    private var timer: Timer?
    private var currentTime: Time = Time.now() {
        didSet {
            if currentTime != oldValue {
                updateCells()
                updateContentOffset(animated: true)
            }
        }
    }

    deinit {
        timer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupGestureRecognizer()
        updateTitle()

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
                self?.updateTitle()
            })
            .bind(to: viewModel.applicationSignificantTimeChange)
            .disposed(by: disposeBag)

        viewModel.events
            .do(onNext: { [weak self] events in
                self?.eventsViewLayout.updateLayoutAttributes(with: events)
            })
            .drive(eventsView.rx.items(cellIdentifier: "EventCell", cellType: EventCell.self)) { _, event, cell in
                cell.event = event
            }
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateContentOffset(animated: true)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.currentTime = Time.now()
        }
    }

    @IBAction func handleNowButtonItemTap(_ sender: Any) {
        updateContentOffset(animated: true)
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

    private func updateTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        navigationItem.title = dateFormatter.string(from: Date())
    }

    private func updateCells() {
        timesView.visibleCells.forEach { cell in
            (cell as? TimeCell)?.updateStyleIfNeeded()
        }
        eventsView.visibleCells.forEach { cell in
            (cell as? EventCell)?.updateStyleIfNeeded()
        }
    }

    private func updateContentOffset(animated: Bool) {
        let currentContentOffsetY = max(min(TimesViewLayout.y(of: currentTime) - timesView.bounds.height / 2, timesView.contentSize.height), 0)
        timesView.setContentOffset(CGPoint(x: 0, y: currentContentOffsetY), animated: animated)
    }
}

extension CalendarViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == timesView {
            eventsView.contentOffset = scrollView.contentOffset
        }
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? TimeCell {
            cell.updateStyleIfNeeded()
        }
        if let cell = cell as? EventCell {
            cell.updateStyleIfNeeded()
        }
    }
}
