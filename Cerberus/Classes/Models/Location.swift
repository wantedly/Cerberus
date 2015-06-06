import Foundation
import Realm

final class Location : RLMObject {
    dynamic var name: String = ""

    init(name: String) {
        super.init()
        self.name = name
    }

    class func find(name: String) -> Location? {
        if let locations = Location.objectsWithPredicate(NSPredicate(format: "name = %@", name)) {
            return locations.firstObject() as? Location
        }

        return nil
    }

    class func findOrCreate(name: String) -> Location! {
        if let location = find(name) {
            return location
        } else {
            let location = Location(name: name)
            location.save()
            return location
        }
    }

    func save() {
        let realm = RLMRealm.defaultRealm()

        realm.transactionWithBlock { [weak self] in
            if let strongSelf = self {
                realm.addObject(strongSelf)
            }
        }
    }
}