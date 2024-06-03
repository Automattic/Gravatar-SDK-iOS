import UIKit
import GravatarUI

class TableViewController: UITableViewController {
    private static let cellID = "ProfileCell"

    lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID) ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellID)

        let config = self?.models[itemIdentifier]
        cell.contentConfiguration = config

        return cell
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()

    var models = [String: ProfileViewConfiguration]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Boilerplate: Adding a default section to the table view
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)

        // Adding a new profile.
        // Note: Use a real Gravatar account email
        addProfile(with: "your@email.com")
    }

    func addProfile(with email: String) {
        guard !email.isEmpty else { return }

        var config = ProfileViewConfiguration.summary()
        config.isLoading = true
        models[email] = config

        snapshot.appendItems([email])
        dataSource.apply(snapshot)
    }
}

enum Section {
    case main
}
