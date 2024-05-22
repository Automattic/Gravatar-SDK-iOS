import GravatarUI
import SnapshotTesting
import XCTest

final class ProfileViewActionsTests: XCTestCase {
    var delegate = TestProfileViewDelegate()

    override func setUp() async throws {
        delegate = TestProfileViewDelegate()
    }

    func testProfileViewButtonsActions() throws {
        let model = TestProfileCardModel.fullCard()

        let profileView = ProfileView(frame: .zero)
        profileView.delegate = delegate
        profileView.update(with: model)

        profileView.profileButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(delegate.profileButtonActions.count, 1)
        XCTAssertEqual(delegate.profileButtonActions.first?.url?.absoluteString, model.profileURL?.absoluteString)

        profileView.accountButtonsStackView.arrangedSubviews.forEach(tap)

        XCTAssertEqual(delegate.accountButtonActions.count, 4)
        XCTAssertEqual(delegate.accountButtonActions.first?.shortname, "gravatar")
        XCTAssertEqual(delegate.accountButtonActions.last?.shortname, "unknown")
    }

    func testProfileSummaryViewButtonsActions() throws {
        let model = TestProfileCardModel.summaryCard()

        let profileView = ProfileSummaryView(frame: .zero)
        profileView.delegate = delegate
        profileView.update(with: model)

        profileView.profileButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(delegate.profileButtonActions.count, 1)
        XCTAssertEqual(delegate.profileButtonActions.first?.url?.absoluteString, model.profileURL?.absoluteString)

        profileView.accountButtonsStackView.arrangedSubviews.forEach(tap)

        XCTAssertEqual(delegate.accountButtonActions.count, 0)
    }

    func testLargeProfileViewButtonsActions() throws {
        let model = TestProfileCardModel.fullCard()

        let profileView = LargeProfileView(frame: .zero)
        profileView.delegate = delegate
        profileView.update(with: model)

        profileView.profileButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(delegate.profileButtonActions.count, 1)
        XCTAssertEqual(delegate.profileButtonActions.first?.url?.absoluteString, model.profileURL?.absoluteString)

        profileView.accountButtonsStackView.arrangedSubviews.forEach(tap)

        XCTAssertEqual(delegate.accountButtonActions.count, 4)
        XCTAssertEqual(delegate.accountButtonActions.first?.shortname, "gravatar")
        XCTAssertEqual(delegate.accountButtonActions.last?.shortname, "unknown")
    }

    func testLargeProfileSummaryViewButtonsActions() throws {
        let model = TestProfileCardModel.summaryCard()

        let profileView = LargeProfileSummaryView(frame: .zero)
        profileView.delegate = delegate
        profileView.update(with: model)

        profileView.profileButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(delegate.profileButtonActions.count, 1)
        XCTAssertEqual(delegate.profileButtonActions.first?.url?.absoluteString, model.profileURL?.absoluteString)

        profileView.accountButtonsStackView.arrangedSubviews.forEach(tap)

        XCTAssertEqual(delegate.accountButtonActions.count, 0)
    }

    func tap(_ view: UIView?) {
        let button = view as? UIButton
        XCTAssertNotNil(button, "View is not a button")
        button?.sendActions(for: .touchUpInside)
    }
}

class TestProfileViewDelegate: NSObject, ProfileViewDelegate {
    var profileButtonActions: [(style: ProfileButtonStyle, url: URL?)] = []
    var accountButtonActions: [AccountModel] = []

    func profileView(_ view: BaseProfileView, didTapOnProfileButtonWithStyle style: ProfileButtonStyle, profileURL: URL?) {
        profileButtonActions.append((style: style, url: profileURL))
    }

    func profileView(_ view: BaseProfileView, didTapOnAccountButtonWithModel accountModel: AccountModel) {
        accountButtonActions.append(accountModel)
    }

    func profileView(_ view: GravatarUI.BaseProfileView, didTapOnAvatarWithID avatarID: Gravatar.AvatarIdentifier?) {}
}
