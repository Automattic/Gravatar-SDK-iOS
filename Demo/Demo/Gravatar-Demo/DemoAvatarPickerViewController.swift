import UIKit
import GravatarUI

class DemoAvatarPickerViewController: DemoBaseProfileViewController {
    let profileView: ProfileView = {
        let view = ProfileView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.profileButtonStyle = .edit
        return view
    }()

    lazy var fetchProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fetch Profile", for: .normal)
        button.contentHorizontalAlignment = .center

        button.addAction(UIAction { [weak self] _ in self?.fetchButtonPressed() }, for: .touchUpInside)
        return button
    }()

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap on the avatar or the Edit Profile button to choose a different avatar."
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        return label
    }()

    var profile: Profile?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground

        [emailField, fetchProfileButton, profileView, label].forEach(rootStackView.addArrangedSubview)

        profileView.delegate = self
    }

    func fetchButtonPressed() {
        guard let email = emailField.text, !email.isEmpty else { return }
        Task {
            let service = ProfileService()
            let profile = try await service.fetch(with: .email(email))
            self.profile = profile
            profileView.update(with: profile)
            profileView.loadAvatar(with: profile.avatarIdentifier)
        }
    }

    func editAvatarButtonPressed() {
        guard profile != nil, let email = emailField.text, !email.isEmpty else { return }
        Task {
            let picker = ProfileEditorViewController(profileID: .init(email), configuration: await Configuration.shared)
            show(picker, sender: self)
        }
    }
}

extension DemoAvatarPickerViewController: ProfileViewDelegate {
    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnProfileButtonWithStyle style: GravatarUI.ProfileButtonStyle, profileURL: URL?) {
        editAvatarButtonPressed()
    }
    
    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnAccountButtonWithModel accountModel: any GravatarUI.AccountModel) {
        // no-op
    }
    
    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnAvatarWithID avatarID: Gravatar.AvatarIdentifier?) {
        editAvatarButtonPressed()
    }
}
