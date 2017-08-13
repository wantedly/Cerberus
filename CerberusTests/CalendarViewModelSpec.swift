import Quick
import Nimble
import EventKit
import EventKitUI
import RxSwift

@testable import Cerberus

class CalendarViewModelSpec: QuickSpec {
    override func spec() {
        var calendarViewModel: CalendarViewModel!
        var calendarService: MockCalendarService!
        var wireframe: MockWireframe!
        var disposeBag: DisposeBag!

        beforeEach {
            calendarService = MockCalendarService()
            wireframe = MockWireframe()
            calendarViewModel = CalendarViewModel(calendarService: calendarService, wireframe: wireframe)
            disposeBag = DisposeBag()
        }

        describe("subscribing of events") {
            context("when the access request is failed with an error") {
                let error = MockError()

                beforeEach {
                    calendarService.requestAccessToEventClosure = { .error(error) }
                }

                it("prompts for a passed error") {
                    var passedError: MockError?
                    wireframe.promptClosure = { error in
                        passedError = error as? MockError
                        return .empty()
                    }

                    calendarViewModel.events
                        .subscribe()
                        .disposed(by: disposeBag)

                    expect(passedError).toEventually(beIdenticalTo(error))
                }
            }

            context("when the access request is denied") {
                beforeEach {
                    calendarService.requestAccessToEventClosure = { .just(false) }
                }

                it("presents a calendar chooser") {
                    var called = false
                    MockCalendarService.chooseCalendarsClosure = { _, _, _ in
                        called = true
                        return .empty()
                    }

                    calendarViewModel.events
                        .subscribe()
                        .disposed(by: disposeBag)

                    expect(called).toEventually(beTrue())
                }
            }

            context("when the access request is granted") {
                beforeEach {
                    calendarService.requestAccessToEventClosure = { .just(true) }
                }

                context("with saved calendars") {
                    let savedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])

                    beforeEach {
                        calendarService.loadedCalendarsClosure = { savedCalendars }
                    }

                    it("fetches today events from the saved calendars") {
                        var fetchedCalendars: Set<EKCalendar>?
                        calendarService.fetchTodayEventsClosure = { calendars in
                            fetchedCalendars = calendars
                            return .empty()
                        }

                        calendarViewModel.events
                            .subscribe()
                            .disposed(by: disposeBag)

                        expect(fetchedCalendars).toEventually(equal(savedCalendars))
                    }
                }

                context("without saved calendars") {
                    beforeEach {
                        calendarService.loadedCalendarsClosure = { nil }
                    }

                    it("saves choosed calendars") {
                        let choosedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
                        var savedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in
                            return .just(choosedCalendars)
                        }
                        MockCalendarService.savedCalendarsClosure = { calendars in
                            savedCalendars = calendars
                        }

                        calendarViewModel.events
                            .subscribe()
                            .disposed(by: disposeBag)

                        expect(savedCalendars).toEventually(equal(choosedCalendars))
                    }
                }
            }
        }
    }
}
