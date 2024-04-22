import UIKit
import Gravatar
import GravatarUI
import SafariServices

class DemoLargeProfileViewController: UIViewController {
    
    let emailField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.textContentType = .emailAddress
        textField.textAlignment = .center
        return textField
    }()

    lazy var fetchProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Fetch Profile", for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(fetchProfileButtonHandler), for: .touchUpInside)
        return button
    }()

    let activityIndicator = UIActivityIndicatorView(style: .large)

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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarImageView.gravatar.activityIndicatorType = .activity
        view.delegate = self
        return view
    }()

    lazy var profileSummaryView: ProfileSummaryView = {
        let view = ProfileSummaryView(frame: .zero, paletteType: preferredPaletteType)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarImageView.gravatar.activityIndicatorType = .activity
        view.delegate = self
        return view
    }()

    lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailField, paletteButton, fetchProfileButton, activityIndicator])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        stack.alignment = .fill

        return stack
    }()

    private lazy var paletteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Palette: \(preferredPaletteType.name)", for: .normal)
        button.addTarget(self, action: #selector(selectPalette), for: .touchUpInside)
        return button
    }()
    
    let paletteTypes: [PaletteType] = [.system, .light, .dark]
    
    var preferredPaletteType: PaletteType = .system {
        didSet {
            largeProfileView.paletteType = preferredPaletteType
            largeProfileSummaryView.paletteType = preferredPaletteType
            profileView.paletteType = preferredPaletteType
            profileSummaryView.paletteType = preferredPaletteType
        }
    }

    let scrollView = UIScrollView()

    override func loadView() {
        scrollView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: -20)
        view = scrollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fetch Profile"

        view.backgroundColor = .secondarySystemBackground

        view.addSubview(rootStackView)
        rootStackView.addArrangedSubview(largeProfileView)
        rootStackView.addArrangedSubview(largeProfileSummaryView)
        rootStackView.addArrangedSubview(profileView)
        rootStackView.addArrangedSubview(profileSummaryView)

        NSLayoutConstraint.activate([
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            rootStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            rootStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }
    
    @objc private func selectPalette() {
        let controller = UIAlertController(title: "Palette", message: nil, preferredStyle: .actionSheet)

        paletteTypes.forEach { option in
            controller.addAction(UIAlertAction(title: "\(option.name)", style: .default) { [weak self] action in
                guard let title = action.title else { return }
                switch title {
                case PaletteType.system.name:
                    self?.preferredPaletteType = PaletteType.system
                case PaletteType.light.name:
                    self?.preferredPaletteType = PaletteType.light
                case PaletteType.dark.name:
                    self?.preferredPaletteType = PaletteType.dark
                default:
                    self?.preferredPaletteType = PaletteType.system
                }
                self?.paletteButton.setTitle("Palette: \(self?.preferredPaletteType.name ?? "")", for: .normal)
            })
        }

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }

    @objc func fetchProfileButtonHandler() {
        var identifier: ProfileIdentifier
        guard let email = emailField.text, email.isEmpty == false else { return }
        identifier = .email(email)

        guard activityIndicator.isAnimating == false else { return }
        
        activityIndicator.startAnimating()
        let service = ProfileService()
        Task {
            defer { activityIndicator.stopAnimating() }
            do {
                let profile = try await service.fetch(with: identifier)
                largeProfileView.update(with: profile)
                largeProfileView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
                largeProfileSummaryView.update(with: profile)
                largeProfileSummaryView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
                profileView.update(with: profile)
                profileView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
                profileSummaryView.update(with: profile)
                profileSummaryView.loadAvatar(with: profile.avatarIdentifier, options: [.transition(.fade(0.2))])
            } catch {
                print(error)
            }
        }
    }
}

extension DemoLargeProfileViewController: ProfileViewDelegate {
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
