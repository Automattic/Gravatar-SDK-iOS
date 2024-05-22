import GravatarUI
import SnapshotTesting
import XCTest

final class LargeProfileViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
    }

    let palettesToTest: [PaletteType] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testLargeProfileView() throws {
        for paletteType in palettesToTest {
            let (cardView, containerView) = createViews(paletteType: paletteType)
            cardView.update(with: TestProfileCardModel.fullCard())
            cardView.avatarImageView.backgroundColor = .blue
            assertSnapshot(of: containerView, as: .image, named: "testLargeProfileView-\(paletteType.name)")
        }
    }

    func testInitiallyEmptyLargeProfileView() throws {
        for paletteType in palettesToTest {
            let (_, containerView) = createViews(paletteType: paletteType)
            assertSnapshot(of: containerView, as: .image, named: "\(paletteType.name)")
        }
    }

    func testLargeProfileViewPlaceholdersCanShow() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (cardView, containerView) = createViews(paletteType: .light)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: TestProfileCardModel.fullCard())
        cardView.update(with: nil) // clear data and show placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileViewPlaceholdersCanHide() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (cardView, containerView) = createViews(paletteType: .light)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: TestProfileCardModel.fullCard())
        cardView.update(with: nil) // clear data and show placeholders
        cardView.update(with: TestProfileCardModel.summaryCard()) // set data and hide placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileViewPlaceholderCanUpdateColors() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (cardView, containerView) = createViews(paletteType: .light)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.placeholderColorPolicy = .custom(PlaceholderColors(backgroundColor: .purple, loadingAnimationColors: [.green, .blue]))
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileViewLoadingStateClearsWhenEmpty() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (cardView, containerView) = createViews(paletteType: .light)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileViewLoadingStateClearsWhenDataIsPresent() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (cardView, containerView) = createViews(paletteType: .light)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.update(with: TestProfileCardModel.fullCard())
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testLargeProfileViewEmptyState() throws {
        for paletteType in palettesToTest {
            let (cardView, containerView) = createViews(paletteType: paletteType)
            cardView.updateWithClaimProfilePrompt()
            containerView.backgroundColor = .systemBackground
            containerView.overrideUserInterfaceStyle = paletteType.palette.preferredUserInterfaceStyle
            cardView.avatarImageView.backgroundColor = .blue
            assertSnapshot(of: containerView, as: .image, named: "testLargeProfileView-\(paletteType.name)")
        }
    }

    private func createViews(paletteType: PaletteType) -> (LargeProfileView, UIView) {
        let cardView = LargeProfileView(frame: .zero, paletteType: paletteType)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true
        let containerView = cardView.wrapInSuperView(with: Constants.width)
        return (cardView, containerView)
    }
}

struct TestProfileCardModel: ProfileModel {
    var accountsList: [GravatarUI.AccountModel]

    var description: String
    var displayName: String
    var jobTitle: String
    var pronunciation: String
    var pronouns: String
    var location: String
    var avatarIdentifier: Gravatar.AvatarIdentifier?
    var profileURL: URL?

    static func fullCard() -> TestProfileCardModel {
        TestProfileCardModel(
            accountsList: [
                TestAccountModel(serviceLabel: "Gravatar", shortname: "gravatar"),
                TestAccountModel(serviceLabel: "WordPress", shortname: "wordpress"),
                TestAccountModel(serviceLabel: "Tumblr", shortname: "tumblr"),
                TestAccountModel(serviceLabel: "Unknown", shortname: "unknown"),
                TestAccountModel(serviceLabel: "hidden", shortname: "hidden"),
            ],
            description: "Hello, this is something about me.",
            displayName: "username",
            jobTitle: "Engineer",
            pronunciation: "Car-N",
            pronouns: "she/her",
            location: "Neverland",
            avatarIdentifier: .email("email@domain.com"),
            profileURL: URL(string: "https://gravatar.com/profile")
        )
    }

    var profileEditURL: URL? {
        URL(string: "https://gravatar.com/profile")
    }
}

struct TestAccountModel: AccountModel {
    var accountURL: URL?
    var serviceLabel: String
    var shortname: String
    var iconURL: URL?
}
