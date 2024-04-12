import UIKit
import Gravatar
import GravatarUI

class DemoProfileConfigurationViewController: UITableViewController {
    lazy var dataSource = UITableViewDiffableDataSource<Section, ProfileItemIdentifier>(tableView: tableView) { tableView, indexPath, itemIdentifier in
        let cellID = "ProfileCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        cell.contentConfiguration = ProfileViewConfiguration.summary(model: itemIdentifier.model)
        return cell
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, ProfileItemIdentifier>()

    override func viewDidLoad() {
        super.viewDidLoad()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
        dataSource.defaultRowAnimation = .fade

        view.backgroundColor = .secondarySystemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction() { _ in
                self.requestEmail()
            }
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if snapshot.itemIdentifiers.isEmpty {
            requestEmail()
        }
    }

    func requestEmail() {
        let alert = UIAlertController(
            title: "Add Email",
            message: "Insert an email to add a new Gravatar profile",
            preferredStyle: .alert
        )
        var textField: UITextField?
        alert.addTextField { alertTextField in
            textField = alertTextField
        }

        alert.addAction(UIAlertAction(title: "Add", style: .destructive, handler: { action in
            Task {
                await self.addEmail(textField?.text ?? "")
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }

    func addEmail(_ email: String) async {
        guard !email.isEmpty else { return }

        let identifier = ProfileItemIdentifier(email: Email(email))
        snapshot.appendItems([identifier])
        await dataSource.apply(snapshot)

        let service = ProfileService()
        do {
            let profile = try await service.fetch(with: .email(email))
            let updatedIdentifier = identifier.updating(model: profile)
            snapshot.appendItems([updatedIdentifier])
            snapshot.deleteItems([identifier])
            await dataSource.apply(snapshot)
        } catch {
            print(error)
        }
    }
}

enum Section {
    case main
}

struct ProfileItemIdentifier: Hashable {
    static func == (lhs: ProfileItemIdentifier, rhs: ProfileItemIdentifier) -> Bool {
        lhs.email == rhs.email && lhs.model == rhs.model && lhs.id == rhs.id
    }

    let id: UUID
    let email: Email
    let model: UserProfile?

    init(email: Email, model: UserProfile? = nil) {
        self.email = email
        self.model = model
        self.id = UUID()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(email.rawValue)
        hasher.combine(model)
        hasher.combine(id)
    }

    func updating(model: UserProfile) -> Self {
        .init(email: email, model: model)
    }
}
