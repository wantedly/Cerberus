import Foundation

struct Time {
    let hour: Int
    let minute: Int
}

extension Time {
    init(_ date: Date) {
        hour = Calendar.current.component(.hour, from: date)
        minute = Calendar.current.component(.minute, from: date)
    }

    static let strideTime = Time(hour: 0, minute: 30)

    static let timesOfDay: [Time] = {
        let step = Double(strideTime.hour) + Double(strideTime.minute) / 60
        return stride(from: 0.0, to: 24.0, by: step).map {
            let hour = Int($0)
            let minute = Int(60 * ($0 - Double(hour)))
            return Time(hour: hour, minute: minute)
        }
    }()
}

extension Time: Comparable {
    static func < (lhs: Time, rhs: Time) -> Bool {
        if lhs.hour != rhs.hour {
            return lhs.hour < rhs.hour
        } else {
            return lhs.minute < rhs.minute
        }
    }

    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }
}
