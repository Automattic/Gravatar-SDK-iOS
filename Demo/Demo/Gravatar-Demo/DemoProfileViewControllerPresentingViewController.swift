import UIKit
import Gravatar
import GravatarUI

@MainActor
class DemoProfileViewControllerPresentingViewController: DemoBaseProfileViewController, UISheetPresentationControllerDelegate {
    
    lazy var showBottomSheetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Profile Bottom Sheet", for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(showBottomSheetButtonHandler), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile View Controller"
        [emailField, profileStylesButton, paletteButton, showBottomSheetButton].forEach(rootStackView.addArrangedSubview)
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
            let viewController = ProfileViewController(configuration: newConfig(), viewModel: .init(), profileIdentifier: profileIdentifier)
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
    
    func newConfig() -> ProfileViewConfiguration {
        switch preferredProfileStyle {
        case .large:
            return ProfileViewConfiguration.large(palette: preferredPaletteType)
        case .largeSummary:
            return ProfileViewConfiguration.largeSummary(palette: preferredPaletteType)
        case .standard:
            return ProfileViewConfiguration.standard(palette: preferredPaletteType)
        case .summary:
            return ProfileViewConfiguration.summary(palette: preferredPaletteType)
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        profileViewController = nil
    }
}
