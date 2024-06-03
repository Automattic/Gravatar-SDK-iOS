import Gravatar
import GravatarUI
import SnapshotTesting
@testable import TestHelpers
import XCTest

final class ProfileViewSnapshots: XCTestCase {
    enum Constants {
        static let width: CGFloat = 320
    }

    override func setUp() async throws {
        try await super.setUp()
        // isRecording = true
    }

    @MainActor
    func testProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = ProfileView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "profileView")
        }
    }

    @MainActor
    func testProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = ProfileSummaryView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "profileSummaryView")
        }
    }

    @MainActor
    func testLargeProfileView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = LargeProfileView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "largeProfileView")
        }
    }

    @MainActor
    func testLargeProfileSummaryView() throws {
        for interfaceStyle in UIUserInterfaceStyle.allCases {
            let profileView = LargeProfileSummaryView()
            profileView.update(with: TestProfileCardModel.exampleModel)
            let containerView = wrap(profileView)
            containerView.overrideUserInterfaceStyle = interfaceStyle
            let postfix = interfaceStyle == .dark ? "view-dark" : "view"
            assertSnapshot(of: containerView, as: .image, named: postfix, testName: "largeProfileSummaryView")
        }
    }

    @MainActor
    private func wrap(_ view: BaseProfileView) -> UIView {
        view.avatarImageView?.backgroundColor = .systemBlue
        view.avatarImageView?.image = ImageHelper.exampleAvatarImage
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: Constants.width).isActive = true

        return view.wrapInSuperView(with: Constants.width)
    }
}

extension TestProfileCardModel {
    @MainActor
    fileprivate static let exampleModel = TestProfileCardModel(
        accountsList: [
            TestAccountModel(serviceLabel: "Gravatar", shortname: "gravatar"),
            TestAccountModel(serviceLabel: "WordPress", shortname: "wordpress"),
            TestAccountModel(serviceLabel: "Tumblr", shortname: "tumblr"),
            TestAccountModel(serviceLabel: "GitHub", shortname: "github"),
        ],
        description: "Engineer at heart, problem-solver by nature. Passionate about innovation and pushing boundaries. Let's build something incredible together.",
        displayName: "John Appleseed",
        jobTitle: "Engineer",
        pronunciation: "",
        pronouns: "he/him",
        location: "Atlanta GA",
        avatarIdentifier: .email("email@domain.com"),
        profileURL: URL(string: "https://gravatar.com/profile")
    )
}
