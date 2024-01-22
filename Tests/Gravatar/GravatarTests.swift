import XCTest
@testable import Gravatar

final class GravatarTests: XCTestCase {
    func testExample() throws {
        XCTAssertEqual(GravatarDataProvider.hash(email: "test@example.com"), "973dfe463ec85785f5f95af5ba3906eedb2d931c24e69824a89ea65dba4e813b")
    }
}
