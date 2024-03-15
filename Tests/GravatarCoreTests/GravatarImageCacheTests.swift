@testable import GravatarCore
import XCTest

final class GravatarImageCacheTests: XCTestCase {
    private let key: String = "key"

    func testSetAndGet() throws {
        let cache = ImageCache()
        cache.setImage(ImageHelper.testImage, forKey: key)
        XCTAssertNotNil(cache.getImage(forKey: key))
    }
}
