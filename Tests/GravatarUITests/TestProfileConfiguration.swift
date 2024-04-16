import GravatarUI
import XCTest

final class TestProfileConfiguration: XCTestCase {
    @MainActor
    func testUpdatePaddingConnfigurationOnStandardViewStyle() throws {
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
    func testUpdatePaddingConnfigurationOnSummaryViewStyle() throws {
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
}
