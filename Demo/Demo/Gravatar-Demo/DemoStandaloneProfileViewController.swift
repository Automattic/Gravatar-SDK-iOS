import UIKit
import Gravatar
import GravatarUI

@MainActor
class DemoStandaloneProfileViewController: BaseDemoProfileViewController {
    
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
        let detailViewController = ProfileViewController(configuration: newConfig(), viewModel: .init(profileIdentifier: .email(emailField.text ?? "")))
        presentInBottomSheet(detailViewController)
    }
    
    func presentInBottomSheet(_ detailViewController: ProfileViewController) {
        let nav = UINavigationController(rootViewController: detailViewController)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        detailViewController.profileFetchingErrorHandler = { error in
            print("Error when fetching profile! \(String(describing: error))")
        }
        present(nav, animated: true, completion: nil)
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
}
