import UIKit
import GravatarUI

@MainActor
class DemoProfilePresentationStylesViewController: DemoBaseProfileViewController, UISheetPresentationControllerDelegate {
    
    lazy var showBottomSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Profile Bottom Sheet", for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(showBottomSheetButtonHandler), for: .touchUpInside)
        return button
    }()
    
    private lazy var customizeAvatarSwitchWithLabel: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Customize Avatar")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile View Controller"
        [emailField, profileStylesButton, paletteButton, customizeAvatarSwitchWithLabel, showBottomSheetButton].forEach(rootStackView.addArrangedSubview)
        rootStackView.alignment = .center
    }
    
    @objc func showBottomSheetButtonHandler() {
        let profileIdentifier: ProfileIdentifier? = emailField.text?.count ?? 0 > 0 ? .email(emailField.text ?? "") : nil
        if let profileViewController {
            profileViewController.clear()
            if let profileIdentifier {
                profileViewController.fetchProfile(profileIdentifier: profileIdentifier)
            }
        }
        else {
            let viewController = ProfileViewController(configuration: newConfig(email: emailField.text ?? ""), viewModel: .init(), profileIdentifier: profileIdentifier)
            self.profileViewController = viewController
            presentInBottomSheet(viewController)
        }
    }
    
    var bottomSheetNavigationViewController: UINavigationController? {
        didSet {
            preferredPaletteTypeChanged()
        }
    }
    
    var profileViewController: ProfileViewController?
    
    func presentInBottomSheet(_ viewController: ProfileViewController) {
        let nav = UINavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [
                .medium()
            ]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.delegate = self
        }
        bottomSheetNavigationViewController = nav
        viewController.profileFetchingErrorHandler = { error in
            print("Error when fetching profile! \(String(describing: error))")
        }
        present(nav, animated: true, completion: nil)
    }
    
    override func preferredPaletteTypeChanged() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = preferredPaletteType.palette.background.primary
        bottomSheetNavigationViewController?.navigationBar.standardAppearance = appearance
        bottomSheetNavigationViewController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func newConfig(email: String) -> ProfileViewConfiguration {
        var config: ProfileViewConfiguration
        switch preferredProfileStyle {
        case .large:
            config = ProfileViewConfiguration.large(palette: preferredPaletteType)
        case .largeSummary:
            config = ProfileViewConfiguration.largeSummary(palette: preferredPaletteType)
        case .standard:
            config = ProfileViewConfiguration.standard(palette: preferredPaletteType)
        case .summary:
            config = ProfileViewConfiguration.summary(palette: preferredPaletteType)
        }
        config.avatarIdentifier = .email(email)
        if customizeAvatarSwitchWithLabel.isOn {
            config.avatarConfiguration.borderColor = .green
            config.avatarConfiguration.borderWidth = 3
            config.avatarConfiguration.cornerRadiusCalculator = { avatarLength in
                return avatarLength / 8
            }
        }
        return config
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        profileViewController = nil
    }
}
