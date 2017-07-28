import UIKit

class TimesViewDataSource: NSObject, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Time.timesOfDay.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath)
        let time = Time.timesOfDay[indexPath.row]
        (cell as? TimeCell)?.update(with: time)
        return cell
    }
}
