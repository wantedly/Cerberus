import UIKit
import RealmSwift

class LocationsTableViewController : UITableViewController {

    var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()

        for location in Realm().objects(Location) {
            self.locations.append(location as Location)
        }

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: TableViewCellreuseIdentifier.LocationCell.rawValue)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(TableViewCellreuseIdentifier.LocationCell.rawValue, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel!.text = self.locations[indexPath.row].name
        return cell
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println(indexPath) // Hmm....
    }
}