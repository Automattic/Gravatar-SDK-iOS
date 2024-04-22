import Gravatar
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

    func testEmptyLargeProfileView() throws {
        for paletteType in palettesToTest {
            let (cardView, containerView) = createViews(paletteType: paletteType)
            assertSnapshot(of: containerView, as: .image, named: "testEmptyLargeProfileView-\(paletteType.name)")
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
    var gravatarAccount: GravatarUI.AccountModel

    var accountsList: [GravatarUI.AccountModel]?

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
            gravatarAccount: TestAccountModel(display: "Gravatar", shortname: "gravatar"),
            accountsList: [
                TestAccountModel(display: "WordPress", shortname: "wordpress"),
                TestAccountModel(display: "Tumblr", shortname: "tumblr"),
                TestAccountModel(display: "Unknown", shortname: "unknown"),
                TestAccountModel(display: "hidden", shortname: "hidden"),
            ],
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

struct TestAccountModel: AccountModel {
    var accountURL: URL?
    var display: String
    var shortname: String
    var iconURL: URL?
}
