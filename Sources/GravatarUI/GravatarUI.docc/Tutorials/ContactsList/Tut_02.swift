import UIKit
import GravatarUI

class TableViewController: UITableViewController {
    private static let cellID = "ProfileCell"

    lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID) ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellID)

        return cell
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()

    var models = [String: ProfileViewConfiguration]()

    func addProfile(with email: String) {
        guard !email.isEmpty else { return }

        // Summary profile view configuration.
        var config = ProfileViewConfiguration.summary()
        // Set in loading state
        config.isLoading = true
        // Store the configuration to get access to it later on.
        models[email] = config
    }
}

enum Section {
    case main
}
