import UIKit
import GravatarUI
import SafariServices

class DemoProfileViewsViewController: DemoBaseProfileViewController {

    lazy var fetchProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fetch Profile", for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(fetchProfileButtonHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndictorSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Test activity indicator (only works when cards are empty)")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.switchView.addTarget(self, action: #selector(toggleLoadingState), for: .valueChanged)
        return view
    }()
    
    lazy var largeProfileView: LargeProfileView = {
        let view = LargeProfileView(frame: .zero, paletteType: preferredPaletteType)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarImageView.gravatar.activityIndicatorType = .activity
        view.delegate = self
        return view
    }()

    lazy var largeProfileSummaryView: LargeProfileSummaryView = {
        let view = LargeProfileSummaryView(frame: .zero, paletteType: preferredPaletteType)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarImageView.gravatar.activityIndicatorType = .activity
        view.delegate = self
        return view
    }()

    lazy var profileView: ProfileView = {
        let view = ProfileView(frame: .zero, paletteType: preferredPaletteType)
        view.profileButtonStyle = .edit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarImageView.gravatar.activityIndicatorType = .activity
        view.delegate = self
        return view
    }()

    lazy var profileSummaryView: ProfileSummaryView = {
        let view = ProfileSummaryView(frame: .zero, paletteType: preferredPaletteType, profileButtonStyle: .edit)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarImageView.gravatar.activityIndicatorType = .activity
        view.delegate = self
        return view
    }()

    override func preferredPaletteTypeChanged() {
        largeProfileView.paletteType = preferredPaletteType
        largeProfileSummaryView.paletteType = preferredPaletteType
        profileView.paletteType = preferredPaletteType
        profileSummaryView.paletteType = preferredPaletteType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fetch Profile"
        [emailField, paletteButton, fetchProfileButton, activityIndictorSwitchWithLabel, largeProfileView, largeProfileSummaryView, profileView, profileSummaryView].forEach(rootStackView.addArrangedSubview)
    }
    
    @objc func toggleLoadingState() {
        updateLoading(isLoading: activityIndictorSwitchWithLabel.isOn)
    }

    private func updateLoading(isLoading: Bool) {
        largeProfileView.isLoading = isLoading
        largeProfileSummaryView.isLoading = isLoading
        profileView.isLoading = isLoading
        profileSummaryView.isLoading = isLoading
    }
    
    @objc func fetchProfileButtonHandler() {
        var identifier: ProfileIdentifier
        guard let email = emailField.text, email.isEmpty == false else { return }
        identifier = .email(email)

        guard largeProfileView.isLoading == false else { return }
        
        updateLoading(isLoading: true)
        let service = ProfileService()
        Task {
            defer { updateLoading(isLoading: false) }
            do {
                let profile = try await service.fetch(with: identifier)
                largeProfileView.update(with: profile)
                largeProfileView.profileButtonStyle = .view
                largeProfileView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
                largeProfileSummaryView.update(with: profile)
                largeProfileSummaryView.profileButtonStyle = .view
                largeProfileSummaryView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
                profileView.update(with: profile)
                profileView.profileButtonStyle = .view
                profileView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
                profileSummaryView.update(with: profile)
                profileSummaryView.profileButtonStyle = .view
                profileSummaryView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
            } catch ProfileServiceError.responseError(reason: let reason) where reason.httpStatusCode == 404 {
                largeProfileView.updateWithClaimProfilePrompt()
                largeProfileSummaryView.updateWithClaimProfilePrompt()
                profileView.updateWithClaimProfilePrompt()
                profileSummaryView.updateWithClaimProfilePrompt()
            } catch {
                print(error)
            }
        }
    }
}

extension DemoProfileViewsViewController: ProfileViewDelegate {
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
