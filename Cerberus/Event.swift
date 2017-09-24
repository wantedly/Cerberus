import EventKit

enum EventType {
    case normal(String)
    case empty
}

enum EventPosition {
    case past
    case future
    case current
}

struct Event {
    let type: EventType
    let startDate: Date
    let endDate: Date
}

extension Event {
    init(_ type: EventType, from start: Date, to end: Date) {
        self.type = type
        startDate = start
        endDate = end
    }

    init(_ event: EKEvent) {
        type = .normal(event.title)
        startDate = event.startDate
        endDate = event.endDate
    }

    var startTime: Time {
        return Time(startDate)
    }

    var endTime: Time {
        return Time(endDate)
    }

    var position: EventPosition {
        let now = Date()
        switch (startDate, endDate) {
        case let (startDate, endDate) where startDate <= now && now <= endDate:
            return .current
        case let (startDate, _) where startDate < now:
            return .past
        default:
            return .future
        }
    }
}
