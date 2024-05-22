import GravatarUI
import XCTest

final class TestProfileConfiguration: XCTestCase {
    @MainActor
    func testUpdatePaddingConfigurationOnStandardViewStyle() throws {
        let expectedPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        var config = ProfileViewConfiguration.standard()
        config.padding = expectedPadding

        let view = config.makeContentView()
        XCTAssertEqual(view.layoutMargins, expectedPadding)

        var updatedConfig = view.configuration as! ProfileViewConfiguration
        updatedConfig.padding = .zero

        view.configuration = updatedConfig

        XCTAssertEqual(view.layoutMargins, .zero)
    }

    @MainActor
    func testUpdatePaddingConfigurationOnSummaryViewStyle() throws {
        let expectedPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        var config = ProfileViewConfiguration.standard()
        config.padding = expectedPadding

        let view = config.makeContentView()
        XCTAssertEqual(view.layoutMargins, expectedPadding)

        var updatedConfig = view.configuration as! ProfileViewConfiguration
        updatedConfig.padding = .zero

        view.configuration = updatedConfig

        XCTAssertEqual(view.layoutMargins, .zero)
    }

    @MainActor
    func testConfigurationOnLargeViewStyle() throws {
        let expectedPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let model = TestProfileCardModel.fullCard()
        var config = ProfileViewConfiguration.large(model: model)
        config.padding = expectedPadding

        let view = config.makeContentView()
        XCTAssertEqual(view.layoutMargins, expectedPadding)

        var updatedConfig = view.configuration as! ProfileViewConfiguration
        updatedConfig.padding = .zero

        view.configuration = updatedConfig

        XCTAssertEqual(view.layoutMargins, .zero)
        XCTAssertEqual((view as? LargeProfileView)?.displayNameLabel.text, model.userName)
    }

    @MainActor
    func testConfigurationOnLargeSummaryViewStyle() throws {
        let expectedPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let model = TestProfileCardModel.summaryCard()
        var config = ProfileViewConfiguration.largeSummary(model: model)
        config.padding = expectedPadding

        let view = config.makeContentView()
        XCTAssertEqual(view.layoutMargins, expectedPadding)

        var updatedConfig = view.configuration as! ProfileViewConfiguration
        updatedConfig.padding = .zero

        view.configuration = updatedConfig

        XCTAssertEqual(view.layoutMargins, .zero)
        XCTAssertEqual((view as? LargeProfileSummaryView)?.displayNameLabel.text, model.userName)
    }

    @MainActor
    func testConfigurationUpdatesProfileButtonStyle() throws {
        let view = ProfileViewConfiguration.largeSummary().makeContentView()
        let profileView = view as! LargeProfileSummaryView

        XCTAssertEqual(profileView.profileButton.titleLabel?.text, nil)

        let model = TestProfileCardModel.summaryCard()
        var config = ProfileViewConfiguration.largeSummary(model: model)
        config.profileButtonStyle = .edit
        profileView.configuration = config

        XCTAssertEqual(profileView.profileButton.titleLabel?.text, "Edit profile")
    }
}
