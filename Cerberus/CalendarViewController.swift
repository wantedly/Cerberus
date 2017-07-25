import UIKit
import RxSwift
import RxCocoa
import RxDataSources

typealias EventsViewDataSource = RxCollectionViewSectionedReloadDataSource<EventSection>

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarsButtonItem: UIBarButtonItem!
    @IBOutlet weak var timesView: UICollectionView!
    @IBOutlet weak var timesViewLayout: TimesViewLayout!
    @IBOutlet weak var eventsView: UICollectionView!
    @IBOutlet weak var eventsViewLayout: EventsViewLayout!
    
    let eventsViewDataSource = EventsViewDataSource()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupGestureRecognizer()
        updateDateOfTitle()
        
        eventsViewDataSource.configureCell = { _, collectionView, indexPath, event in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
            cell.update(with: event)
            return cell
        }
        
        eventsViewLayout.dataSource = eventsViewDataSource
        
        let viewModel = CalendarViewModel(calendarService: CalendarService(), wireframe: Wireframe(rootViewController: self))
        
        calendarsButtonItem.rx.tap
            .bind(to: viewModel.calendersButtonItemDidTap)
            .disposed(by: disposeBag)
        
        viewModel.eventSections
            .do(onNext: { [weak self] _ in self?.updateDateOfTitle() })
            .bind(to: eventsView.rx.items(dataSource: eventsViewDataSource))
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

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Time.timesOfDay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! TimeCell
        let time = Time.timesOfDay[indexPath.row]
        cell.update(with: time)
        return cell
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
