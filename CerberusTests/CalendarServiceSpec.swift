import Quick
import Nimble
import EventKit
import EventKitUI
import RxSwift

@testable import Cerberus

class CalendarServiceSpec: QuickSpec {
    override func spec() {
        describe("chooseCalendars(with:in:defaultCalendars:)") {
            var window: UIWindow!
            var calendarChooser: MockCalendarChooser!
            var disposeBag: DisposeBag!

            beforeEach {
                window = UIWindow()
                window.makeKeyAndVisible()
                window.rootViewController = UIViewController()
                calendarChooser = MockCalendarChooser()
                disposeBag = DisposeBag()
            }

            it("sets calendars passed by an argument") {
                let calendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])

                CalendarService.chooseCalendars(with: calendarChooser, in: window.rootViewController, defaultCalendars: calendars)
                    .subscribe()
                    .disposed(by: disposeBag)

                expect(calendarChooser.setCalendars).toEventually(equal(calendars), timeout: 3)
            }

            it("emits calendars of the calendar chooser with a selection event") {
                var calendars: Set<EKCalendar>?

                CalendarService.chooseCalendars(with: calendarChooser, in: window.rootViewController)
                    .subscribe(onNext: { calendars = $0 })
                    .disposed(by: disposeBag)
                calendarChooser.delegate!.calendarChooserSelectionDidChange!(calendarChooser)

                expect(calendars).toEventually(equal(calendarChooser.selectedCalendars), timeout: 3)
            }

            it("completes with a finish event") {
                var completed = false

                CalendarService.chooseCalendars(with: calendarChooser, in: window.rootViewController)
                    .subscribe(onCompleted: { completed = true })
                    .disposed(by: disposeBag)
                calendarChooser.delegate!.calendarChooserDidFinish!(calendarChooser)

                expect(completed).toEventually(beTrue(), timeout: 3)
            }
        }
    }
}
