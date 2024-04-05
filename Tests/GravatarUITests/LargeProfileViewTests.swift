import Gravatar
import GravatarUI
import SnapshotTesting
import XCTest

final class LargeProfileViewTests: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
        static let containerHeight: CGFloat = 350
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

    private func createViews(paletteType: PaletteType) -> (LargeProfileView, UIView) {
        let cardView = LargeProfileView(frame: .zero, paletteType: paletteType)
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

struct TestProfileCardModel: ProfileCardModel {
    var aboutMe: String?
    var displayName: String?
    var fullName: String?
    var userName: String
    var jobTitle: String?
    var pronunciation: String?
    var pronouns: String?
    var currentLocation: String?
    var avatarIdentifier: Gravatar.AvatarIdentifier

    static func fullCard() -> TestProfileCardModel {
        TestProfileCardModel(
            aboutMe: "Hello, this is something about me.",
            displayName: "Display Name",
            fullName: "Name Surname",
            userName: "username",
            jobTitle: "Engineer",
            pronunciation: "Car-N",
            pronouns: "she/her",
            currentLocation: "Neverland",
            avatarIdentifier: .email("email@domain.com")
        )
    }
}
