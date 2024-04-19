import Gravatar
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
            let containerView = createViews(model: TestProfileCardModel.summaryCard())
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "\(interfaceStyle.name)")
        }
    }

    func testEmptyProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let containerView = createViews(model: nil)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            assertSnapshot(of: containerView, as: .image, named: "empty-\(interfaceStyle.name)")
        }
    }

    private func createViews(model: ProfileSummaryModel?) -> UIView {
        let cardView = LargeProfileSummaryView(frame: .zero, paletteType: .system)
        cardView.update(with: model)
        if model != nil {
            cardView.avatarImageView.backgroundColor = .systemBlue
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return cardView.wrapInSuperView(with: Constants.width)
    }
}

extension TestProfileCardModel {
    static func summaryCard() -> TestProfileCardModel {
        .fullCard()
    }
}
