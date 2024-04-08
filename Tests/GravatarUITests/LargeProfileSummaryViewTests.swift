import Gravatar
import GravatarUI
import SnapshotTesting
import XCTest

final class LargeProfileSummaryViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
        static let containerHeight: CGFloat = 350
    }

    let palettesToTest: [PaletteType] = [.light, .dark]

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    func testLargeProfileSummaryView() throws {
        for paletteType in palettesToTest {
            let (cardView, containerView) = createViews(paletteType: paletteType)
            cardView.update(with: TestProfileCardModel.summaryCard())
            cardView.avatarImageView.backgroundColor = .blue
            assertSnapshot(of: containerView, as: .image, named: "\(paletteType.name)")
        }
    }

    private func createViews(paletteType: PaletteType) -> (LargeProfileSummaryView, UIView) {
        let cardView = LargeProfileSummaryView(frame: .zero, paletteType: paletteType)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true
        let containerView = UIView()
        containerView.backgroundColor = .purple
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: Constants.width + 20).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: Constants.containerHeight).isActive = true
        containerView.addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        cardView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        return (cardView, containerView)
    }
}

extension TestProfileCardModel: ProfileCardSummaryModel {
    static func summaryCard() -> TestProfileCardModel {
        .fullCard()
    }
}
