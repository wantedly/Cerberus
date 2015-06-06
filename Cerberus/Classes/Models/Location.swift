import Foundation
import RealmSwift

final class Location : Object {
    dynamic var name: String = ""

    /*
    override class func primaryKey() -> String {
        return "name"
    }
    */

    class func find(name: String) -> Location? {
        let locations = Realm().objects(Location).filter(NSPredicate(format: "name = %@", name))
        return locations.first
    }

    class func findOrCreate(name: String) -> Location! {
        if let location = find(name) {
            return location
        } else {
            let location = Location()
            location.name = name
            location.save()
            return location
        }
    }

    func save() {
        let realm = Realm()

        realm.write { [weak self] in
            if let strongSelf = self {
                realm.add(strongSelf)
            }
        }
    }
}