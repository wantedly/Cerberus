import Foundation

struct UserDefaultsKeys {
    struct Key<T> {
        let rawValue: String
    }
    
    static let calendarIdentifiers = Key<[String]>(rawValue: "calendarIdentifiers")
}

extension UserDefaults {
    func value<T>(for key: UserDefaultsKeys.Key<T>) -> T? {
        return value(forKey: key.rawValue) as? T
    }
    
    func set<T>(value: T?, for key: UserDefaultsKeys.Key<T>) {
        set(value, forKey: key.rawValue)
    }
}
