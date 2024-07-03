import Gravatar
import UIKit

/// Base controller to edit a profile, given a profile ID.
public class ProfileEditorViewController: UITabBarController {
    private var profileID: Email

    var isAuthenticated: Bool {
        get async {
            await Configuration.shared.userAuthorizationToken(for: .email(profileID)) != nil
        }
    }

    let configuration: Configuration

    public init(profileID: Email, configuration: Configuration) {
        self.profileID = profileID
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        let initialController = UIViewController()
        initialController.view.backgroundColor = .systemBackground
        viewControllers = [initialController]
        Task {
            await showInitialController()
        }
        title = "Editor"

        let menu = UIMenu(children: [
            UIAction(title: "Log out", handler: { [weak self] _ in self?.logout() }),
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "gravatar", in: .module, with: nil),
            menu: menu
        )
    }

    func logout() {
        Task {
            try? await Configuration.shared.setUserAuthorizationToken(nil, for: .email(profileID))
            if let navigationController {
                navigationController.popViewController(animated: true)
            } else if let presentingViewController {
                presentingViewController.dismiss(animated: true)
            }
        }
    }

    func showInitialController() async {
        if let token = await configuration.userAuthorizationToken(for: .email(profileID)) {
            showImagePickerScreen(with: token)
        } else {
            await showAuthScreen()
        }

        // TODO: Show a login prompt when the oauth webview is dismissed without a success.
    }

    func showAuthScreen() async {
        let authenticator = await UserAuthenticator(delegate: self)
        guard let window = view.window else {
            return
        }
        await authenticator.showAuthScreen(on: WebAuthenticationPresentationContextProvider(window: window))
    }

    func showImagePickerScreen(with token: String) {
        let controller = AvatarPickerViewController(email: profileID, authToken: token)
        viewControllers = [controller]
    }
}

extension ProfileEditorViewController: UserAuthenticatorDelegate {
    nonisolated func userAuthenticator(_ authenticator: UserAuthenticator, finishedAuthenticationSuccessfulyWithToken token: String) {
        Task {
            do {
                try await configuration.setUserAuthorizationToken(token, for: .email(profileID))
                await showImagePickerScreen(with: token)
            } catch {
                // TODO: Do something with the error
                print(error)
            }
        }
    }
}
