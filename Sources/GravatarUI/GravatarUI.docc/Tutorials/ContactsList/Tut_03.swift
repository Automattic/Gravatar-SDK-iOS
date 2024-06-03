import UIKit
import GravatarUI

class TableViewController: UITableViewController {
    private static let cellID = "ProfileCell"

    lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID) ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellID)

        // Updating the table view with the new item, we can obtain the configuration from its identifier.
        let config = self?.models[itemIdentifier]
        // Since the ProfileViewConfiguration conforms to `UIContentConfiguration`, we can use it as the cell's contentConfiguration.
        cell.contentConfiguration = config

        return cell
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()

    var models = [String: ProfileViewConfiguration]()

    func addProfile(with email: String) {
        guard !email.isEmpty else { return }

        var config = ProfileViewConfiguration.summary()
        config.isLoading = true
        models[email] = config

        // Adding the profile identifier (email) to the table view's data source.
        // This will trigger the table view update.
        snapshot.appendItems([email])
        dataSource.apply(snapshot)
    }
}

enum Section {
    case main
}
