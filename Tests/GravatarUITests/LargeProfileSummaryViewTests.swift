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

    @MainActor
    func testLargeProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: TestProfileCardModel.summaryCard())
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    @MainActor
    func testInitiallyEmptyLargeProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let (containerView, _) = createViews(model: nil)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    @MainActor
    func testLargeProfileSummaryViewPlaceholdersCanShow() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testLargeProfileSummaryViewPlaceholdersCanHide() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: TestProfileCardModel.summaryCard())
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.update(with: nil) // clear data and show placeholders
        cardView.update(with: TestProfileCardModel.summaryCard()) // set data and hide placeholders
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testLargeProfileSummaryViewPlaceholderCanUpdateColors() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.placeholderColorPolicy = .custom(PlaceholderColors(backgroundColor: .purple, loadingAnimationColors: [.green, .blue]))
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
    func testLargeProfileSummaryViewLoadingStateClearsWhenEmpty() throws {
        let interfaceStyle: UIUserInterfaceStyle = .light
        let (containerView, cardView) = createViews(model: nil)
        containerView.overrideUserInterfaceStyle = interfaceStyle
        cardView.isLoading = true
        cardView.isLoading = false
        assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
    }

    @MainActor
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
    private func createViews(model: ProfileSummaryModel?) -> (UIView, LargeProfileSummaryView) {
        let cardView = LargeProfileSummaryView(frame: .zero, paletteType: .system)
        cardView.update(with: model)
        if model != nil {
            cardView.avatarImageView.backgroundColor = .systemBlue
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
