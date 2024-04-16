import GravatarUI
import XCTest

final class TestProfileConfiguration: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

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
