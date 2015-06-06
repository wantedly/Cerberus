import Foundation

final class Event {
    var title: String = ""
    var location: String?
    
    var startAt: NSDate?
    var endAt: NSDate?
    
    var attendees: [User] = []

    init(title: String) {
        self.title = title
    }
}