import EventKit

enum EventType {
    case normal(String)
    case empty
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
}
