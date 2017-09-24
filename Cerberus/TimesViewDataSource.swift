import UIKit

class TimesViewDataSource: NSObject, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Time.timesOfDay.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath)
        if let cell = cell as? TimeCell {
            cell.time = Time.timesOfDay[indexPath.row]
        }
        return cell
    }
}
