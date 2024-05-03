import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
    }

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: TestProfileCardModel.summaryCard())
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    func testInitiallyEmptyProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: nil)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    func testProfileViewPlaceholdersCanShow() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testProfileViewPlaceholdersCanHide() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        cardView.update(with: TestProfileCardModel.summaryCard()) // set data and hide placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testProfileViewPlaceholderCanUpdateColors() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.placeholderColorPolicy = .custom(PlaceholderColors(backgroundColor: .purple, loadingAnimationColors: [.green, .blue]))
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testProfileViewLoadingStateClearsWhenEmpty() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testProfileViewLoadingStateClearsWhenDataIsPresent() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.update(with: TestProfileCardModel.summaryCard())
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testProfileViewEmptyState() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let interfaceStyle: UIUserInterfaceStyle = interfaceStyle
            let (containerView, cardView) = createViews(model: nil)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            cardView.updateWithClaimProfilePrompt()
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    private func createViews(model: ProfileModel?) -> (UIView, ProfileView) {
        let cardView = ProfileView(frame: .zero, paletteType: .system)
        cardView.update(with: model)
        if model != nil {
            cardView.avatarImageView.backgroundColor = .systemBlue
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return (cardView.wrapInSuperView(with: Constants.width), cardView)
    }
}

extension UIView {
    func wrapInSuperView(with width: CGFloat) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: width + 20).isActive = true

        containerView.addSubview(self)
        topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        return containerView
    }

    func applySize(_ size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
}

extension UIUserInterfaceStyle {
    var name: String {
        switch self {
        case .light: "light"
        case .dark: "dark"
        default: "unknown"
        }
    }

    static var allCases: [UIUserInterfaceStyle] {
        [.light, .dark]
    }
}
