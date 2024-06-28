import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileSummaryViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
    }

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    @MainActor
    func testProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: TestProfileCardModel.summaryCard())
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    @MainActor
    func testInitiallyEmptyProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: nil)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    @MainActor
    func testProfileSummaryViewPlaceholdersCanShow() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testProfileSummaryViewPlaceholdersCanHide() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        cardView.update(with: TestProfileCardModel.summaryCard()) // set data and hide placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testProfileSummaryViewPlaceholdersCanShowCustomPalette() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        cardView.paletteType = .custom(Palette.testPalette)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testProfileSummaryViewPlaceholdersCanHideCustomPalette() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        cardView.paletteType = .custom(Palette.testPalette)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        cardView.update(with: TestProfileCardModel.summaryCard()) // set data and hide placeholders
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testProfileViewSummaryPlaceholderCanUpdateColors() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.placeholderColorPolicy = .custom(PlaceholderColors(backgroundColor: .purple, loadingAnimationColors: [.green, .blue]))
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testProfileViewSummaryLoadingStateClearsWhenEmpty() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testProfileViewSummaryLoadingStateClearsWhenDataIsPresent() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.update(with: TestProfileCardModel.summaryCard())
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testProfileSummaryViewEmptyState() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, profileView) = createViews(model: nil)
            profileView.updateWithClaimProfilePrompt()
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    @MainActor
    func testProfileSummaryViewEmptyStateCustomPalette() throws {
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        cardView.paletteType = .custom(Palette.testPalette)
        cardView.updateWithClaimProfilePrompt()
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testProfileSummaryViewCustomAvatarViewImageViewSubview() {
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            avatarType: .imageView(TestAvatarImageView(frame: .zero))
        )
        containerView.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testProfileSummaryViewCustomAvatarImageViewSubviewCustomStyle() {
        let avatarView = TestAvatarImageView(frame: .zero)
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            avatarType: .imageView(avatarView, skipStyling: true)
        )
        containerView.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        avatarView.applyStyle()
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testProfileSummaryViewCustomAvatarImageViewWrapper() {
        let avatarView = TestAvatarImageViewWrapper(frame: .zero)
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            avatarType: .imageViewWrapper(avatarView)
        )
        containerView.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testProfileSummaryViewCustomAvatarView() {
        let avatarView = TestCustomAvatarView()
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            avatarType: .custom(avatarView)
        )
        containerView.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    private func createViews(model: ProfileSummaryModel?, avatarType: AvatarType? = nil) -> (UIView, ProfileSummaryView) {
        let cardView = ProfileSummaryView(frame: .zero, paletteType: .system, avatarType: avatarType)
        cardView.update(with: model)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return (cardView.wrapInSuperView(with: Constants.width), cardView)
    }
}
