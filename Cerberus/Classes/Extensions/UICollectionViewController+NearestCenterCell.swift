import Foundation

extension UICollectionViewController {
    typealias VisibleCellInfo = (cell: UICollectionViewCell, row: Int, height: CGFloat, deviation: CGFloat)

    func getVisibleCellsAndNearestCenterCell() -> (visibles: [VisibleCellInfo], nearestCenter: VisibleCellInfo!) {
        let collectionViewHeight = self.collectionView!.bounds.height
        let collectionViewY = self.collectionView!.frame.origin.y

        var visibles = [VisibleCellInfo]()
        var nearestCenter: VisibleCellInfo!

        for indexPath in self.collectionView!.indexPathsForVisibleItems() {
            let cell     = self.collectionView!.cellForItemAtIndexPath(indexPath as! NSIndexPath)!
            let cellRect = self.collectionView!.convertRect(cell.frame, toView: self.collectionView?.superview)

            var height = cellRect.height
            var y      = cellRect.origin.y

            if y < collectionViewY {
                height -= collectionViewY - y
                y       = 0
            }

            let deviation = (y + height / 2) / collectionViewHeight - 0.5

            let cellInfo: VisibleCellInfo = (
                cell:      cell,
                row:       indexPath.row,
                height:    height,
                deviation: deviation
            )

            visibles.append(cellInfo)

            if abs(nearestCenter?.deviation ?? CGFloat.infinity) > abs(deviation) {
                nearestCenter = cellInfo
            }
        }

        return (visibles: visibles, nearestCenter: nearestCenter)
    }
}