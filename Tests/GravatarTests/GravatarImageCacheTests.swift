@testable import Gravatar
import XCTest

final class GravatarImageCacheTests: XCTestCase {
    private let key = "ImageKey"

    func testSetAndGet() {
        let cache = ImageCache()
        cache.setEntry(.ready(ImageHelper.testImage), for: key)
        let image = cache.getEntry(with: key)
        XCTAssertNotNil(image)
    }

    func testRequestingMultipleTimes() {
        let cache = ImageCache()
        let task = Task<UIImage, Error> {
            ImageHelper.testImage
        }
        cache.setEntry(.inProgress(task), for: key)
        let image = cache.getEntry(with: key)
        XCTAssertNotNil(image)
    }
}
