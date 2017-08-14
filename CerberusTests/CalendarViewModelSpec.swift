import Quick
import Nimble
import EventKit
import EventKitUI
import RxSwift
import RxCocoa

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
            disposeBag = DisposeBag()
        }

        describe("subscribing of events") {
            beforeEach {
                calendarViewModel = CalendarViewModel(calendarService: calendarService, wireframe: wireframe)
            }

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
                        .drive()
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
                        .drive()
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

                    it("doesn't present a calendar chooser") {
                        var called = false
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in
                            called = true
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)

                        expect(called).toEventually(beFalse())
                    }

                    it("fetches today events from the saved calendars") {
                        var fetchedCalendars: Set<EKCalendar>?
                        calendarService.fetchTodayEventsClosure = { calendars in
                            fetchedCalendars = calendars
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)

                        expect(fetchedCalendars).toEventually(equal(savedCalendars))
                    }
                }

                context("without saved calendars") {
                    beforeEach {
                        calendarService.loadedCalendarsClosure = { nil }
                    }

                    it("presents a calendar chooser") {
                        var called = false
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in
                            called = true
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)

                        expect(called).toEventually(beTrue())
                    }

                    it("saves new calendars by choosed ones") {
                        let choosedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
                        var savedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in .just(choosedCalendars) }
                        MockCalendarService.saveCalendarsClosure = { calendars in
                            savedCalendars = calendars
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)

                        expect(savedCalendars).toEventually(equal(choosedCalendars))
                    }

                    it("fetches today events from the choosed calendars") {
                        let choosedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
                        var fetchedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in .just(choosedCalendars) }
                        calendarService.fetchTodayEventsClosure = { calendars in
                            fetchedCalendars = calendars
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)

                        expect(fetchedCalendars).toEventually(equal(choosedCalendars))
                    }
                }
            }
        }

        describe("a tap event of the calendars button after subscribing of events") {
            beforeEach {
                calendarViewModel = CalendarViewModel(calendarService: calendarService, wireframe: wireframe, shouldStartImmediately: false)
            }

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
                        .drive()
                        .disposed(by: disposeBag)
                    calendarViewModel.calendarsButtonItemDidTap.on(.next())

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
                        .drive()
                        .disposed(by: disposeBag)
                    calendarViewModel.calendarsButtonItemDidTap.on(.next())

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

                    it("presents a calendar chooser with saved calendars") {
                        var called = false
                        var passedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, defaultCalendars in
                            called = true
                            passedCalendars = defaultCalendars
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)
                        calendarViewModel.calendarsButtonItemDidTap.on(.next())

                        expect(called).toEventually(beTrue())
                        expect(passedCalendars).toEventually(equal(savedCalendars))
                    }

                    it("saves choosed calendars") {
                        let choosedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
                        var newlySavedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in .just(choosedCalendars) }
                        MockCalendarService.saveCalendarsClosure = { calendars in
                            newlySavedCalendars = calendars
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)
                        calendarViewModel.calendarsButtonItemDidTap.on(.next())

                        expect(newlySavedCalendars).toNotEventually(equal(savedCalendars))
                        expect(newlySavedCalendars).toEventually(equal(choosedCalendars))
                    }

                    it("fetches today events from the choosed calendars") {
                        let choosedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
                        var fetchedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in .just(choosedCalendars) }
                        calendarService.fetchTodayEventsClosure = { calendars in
                            fetchedCalendars = calendars
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)
                        calendarViewModel.calendarsButtonItemDidTap.on(.next())

                        expect(fetchedCalendars).toEventually(equal(choosedCalendars))
                    }
                }

                context("without saved calendars") {
                    beforeEach {
                        calendarService.loadedCalendarsClosure = { nil }
                    }

                    it("presents a calendar chooser with no calendars") {
                        var called = false
                        var passedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, defaultCalendars in
                            called = true
                            passedCalendars = defaultCalendars
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)
                        calendarViewModel.calendarsButtonItemDidTap.on(.next())

                        expect(called).toEventually(beTrue())
                        expect(passedCalendars).toEventually(beNil())
                    }

                    it("saves choosed calendars") {
                        let choosedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
                        var savedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in .just(choosedCalendars) }
                        MockCalendarService.saveCalendarsClosure = { calendars in
                            savedCalendars = calendars
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)
                        calendarViewModel.calendarsButtonItemDidTap.on(.next())

                        expect(savedCalendars).toEventually(equal(choosedCalendars))
                    }

                    it("fetches today events from the choosed calendars") {
                        let choosedCalendars = Set([EKCalendar(for: .event, eventStore: EKEventStore())])
                        var fetchedCalendars: Set<EKCalendar>?
                        MockCalendarService.chooseCalendarsClosure = { _, _, _ in .just(choosedCalendars) }
                        calendarService.fetchTodayEventsClosure = { calendars in
                            fetchedCalendars = calendars
                            return .empty()
                        }

                        calendarViewModel.events
                            .drive()
                            .disposed(by: disposeBag)
                        calendarViewModel.calendarsButtonItemDidTap.on(.next())

                        expect(fetchedCalendars).toEventually(equal(choosedCalendars))
                    }
                }
            }
        }
    }
}
