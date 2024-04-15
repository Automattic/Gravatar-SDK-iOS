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

    private func createViews(model: ProfileCardSummaryModel) -> UIView {
        let cardView = LargeProfileSummaryView(frame: .zero, paletteType: .system)
        cardView.avatarImageView.backgroundColor = .systemBlue
        cardView.update(with: model)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return cardView.wrapInSuperView(with: Constants.width)
    }
}

extension TestProfileCardModel: ProfileCardSummaryModel {
    static func summaryCard() -> TestProfileCardModel {
        .fullCard()
    }
}
