import UIKit
import GravatarUI
import SafariServices

class DemoProfileConfigurationViewController: UITableViewController {
    lazy var dataSource = UITableViewDiffableDataSource<Section, String>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
        let cellID = "ProfileCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        var config = self?.models[itemIdentifier]
        config?.delegate = self
        cell.contentConfiguration = config
        return cell
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
    var models = [String: ProfileViewConfiguration]()

    override func viewDidLoad() {
        super.viewDidLoad()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot)
        dataSource.defaultRowAnimation = .fade

        view.backgroundColor = .secondarySystemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction() {[weak self] _ in
                self?.requestEmail()
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
        
        var config = ProfileViewConfiguration.standard()
        config.isLoading = true
        models[email] = config
        snapshot.appendItems([email])
        await dataSource.apply(snapshot)

        let service = ProfileService()
        do {
            let profile = try await service.fetch(with: .email(email))
            models[email] = .standard(model: profile)
            snapshot.reloadItems([email])
            await dataSource.apply(snapshot)
        } catch ProfileServiceError.responseError(let reason) where reason.httpStatusCode == 404 {
            models[email] = ProfileView.claimProfileConfiguration()
            snapshot.reloadItems([email])
            await dataSource.apply(snapshot)
        } catch {
            print(error)
        }
    }
}

extension DemoProfileConfigurationViewController: ProfileViewDelegate {
    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnAvatarWithID avatarID: Gravatar.AvatarIdentifier?) {
        print("Avatar tapped!")
        if let avatarID {
            print("Avatar ID: \(AvatarURL(with: avatarID)?.url.absoluteString ?? "")")
        }
    }
    
    func profileView(_ view: BaseProfileView, didTapOnProfileButtonWithStyle style: ProfileButtonStyle, profileURL: URL?) {
        guard let profileURL else { return }
        let safari = SFSafariViewController(url: profileURL)
        present(safari, animated: true)
    }

    func profileView(_ view: BaseProfileView, didTapOnAccountButtonWithModel accountModel: AccountModel) {
        guard let accountURL = accountModel.accountURL else { return }
        let safari = SFSafariViewController(url: accountURL)
        present(safari, animated: true)
    }
}

enum Section {
    case main
}
