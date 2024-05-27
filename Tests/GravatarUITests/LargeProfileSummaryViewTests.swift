import GravatarUI
import SnapshotTesting
import XCTest

final class LargeProfileSummaryViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
    }

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testLargeProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: TestProfileCardModel.summaryCard())
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    func testInitiallyEmptyLargeProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: nil)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    func testLargeProfileSummaryViewPlaceholdersCanShow() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileSummaryViewPlaceholdersCanHide() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        cardView.update(with: TestProfileCardModel.summaryCard()) // set data and hide placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileSummaryViewPlaceholderCanUpdateColors() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.placeholderColorPolicy = .custom(PlaceholderColors(backgroundColor: .purple, loadingAnimationColors: [.green, .blue]))
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileSummaryViewLoadingStateClearsWhenEmpty() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    func testLargeProfileSummaryViewLoadingStateClearsWhenDataIsPresent() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.update(with: TestProfileCardModel.summaryCard())
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testLargeProfileSummaryViewEmptyState() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, profileView) = createViews(model: nil)
            profileView.updateWithClaimProfilePrompt()
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    @MainActor
    func testLargeProfileSummaryCustomAvatarViewImageViewSubview() {
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            paletteType: .light,
            avatarType: .imageView(TestAvatarImageView(frame: .zero)),
            shouldSetAvatarBG: false
        )
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testLargeProfileSummaryViewCustomAvatarImageViewSubviewCustomStyle() {
        let avatarView = TestAvatarImageView(frame: .zero)
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            paletteType: .light,
            avatarType: .imageView(avatarView, skipStyling: true),
            shouldSetAvatarBG: false
        )
        avatarView.applyStyle()
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testLargeProfileSummaryViewCustomAvatarImageViewWrapper() {
        let avatarView = TestAvatarImageViewWrapper(frame: .zero)
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            paletteType: .light,
            avatarType: .imageViewWrapper(avatarView),
            shouldSetAvatarBG: false
        )
        assertSnapshot(of: containerView, as: .image)
    }

    @MainActor
    func testLargeProfileSummaryViewCustomAvatarView() {
        let avatarView = TestCustomAvatarView()
        let (containerView, _) = createViews(
            model: TestProfileCardModel.summaryCard(),
            paletteType: .light,
            avatarType: .custom(avatarView),
            shouldSetAvatarBG: false
        )
        assertSnapshot(of: containerView, as: .image)
    }

    private func createViews(
        model: ProfileSummaryModel?,
        paletteType: PaletteType = .system,
        avatarType: AvatarType? = nil,
        shouldSetAvatarBG: Bool = true
    ) -> (UIView, LargeProfileSummaryView) {
        let cardView = LargeProfileSummaryView(frame: .zero, paletteType: .system, avatarType: avatarType)
        cardView.update(with: model)
        if model != nil && shouldSetAvatarBG {
            cardView.avatarImageView?.backgroundColor = .systemBlue
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return (cardView.wrapInSuperView(with: Constants.width), cardView)
    }
}

extension TestProfileCardModel {
    static func summaryCard() -> TestProfileCardModel {
        .fullCard()
    }
}
