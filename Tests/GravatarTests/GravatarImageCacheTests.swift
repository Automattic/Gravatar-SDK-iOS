import Gravatar
import TestHelpers
import XCTest

final class GravatarImageCacheTests: XCTestCase {
    private let key = "ImageKey"

    override func tearDown() {
        (ImageCache.shared as! ImageCache).clear() // Ensure cache is reset between tests
    }

    func testSetAndGet() {
        let cache = ImageCache.shared
        cache.setEntry(.ready(ImageHelper.testImage), for: key)
        let image = cache.getEntry(with: key)
        XCTAssertNotNil(image)
    }

    func testRequestingMultipleTimes() {
        let cache = ImageCache.shared
        let task = Task<UIImage, Error> {
            ImageHelper.testImage
        }
        cache.setEntry(.inProgress(task), for: key)
        let image = cache.getEntry(with: key)
        XCTAssertNotNil(image)
    }
}
