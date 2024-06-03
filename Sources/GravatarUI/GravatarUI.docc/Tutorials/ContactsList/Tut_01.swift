import UIKit
import GravatarUI

class TableViewController: UITableViewController {
    private static let cellID = "ProfileCell"

    lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID) ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellID)

        return cell
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
}

enum Section {
    // Default section for the table view
    case main
}
