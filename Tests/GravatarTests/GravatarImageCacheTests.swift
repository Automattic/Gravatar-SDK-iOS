@testable import Gravatar
import XCTest

final class GravatarImageCacheTests: XCTestCase {
    private let key = URL(string: "https://image.com/image.png")!

    func testSetAndGet() async throws {
        let cache = ImageCache()
        await cache.setImage(ImageHelper.testImage, for: key)
        let image = try await cache.getImage(for: key)
        XCTAssertNotNil(image)
    }

    func testRequestingMultipleTimes() async throws {
        let cache = ImageCache()
        let task = Task<UIImage, Error> {
            ImageHelper.testImage
        }
        await cache.setTask(task, for: key)
        let image = try await cache.getImage(for: key)
        XCTAssertNotNil(image)
    }
}
