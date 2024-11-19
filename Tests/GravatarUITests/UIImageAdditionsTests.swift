@testable import GravatarUI
import XCTest

final class UIImageAdditionsTests: XCTestCase {
    @MainActor
    func testSquareUnequalEdgesSmallerThanMax() throws {
        let image = createImage(size: .init(width: 96.1, height: 96.0))
        let squareImage = try XCTUnwrap(image.squared(maxSize: .pixels(1024)))
        let targetLength = min(image.size.width * image.scale, image.size.height * image.scale)
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, targetLength)
        XCTAssertEqual(squareImage.size.height * squareImage.scale, targetLength)
    }

    @MainActor
    func testSquareUnequalEdgesBiggerThanMax() throws {
        let maxLength = 50
        let image = createImage(size: .init(width: 96.1, height: 96.0))
        let squareImage = try XCTUnwrap(image.squared(maxSize: .pixels(maxLength)))
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, CGFloat(maxLength))
        XCTAssertEqual(squareImage.size.height * squareImage.scale, CGFloat(maxLength))
    }

    @MainActor
    func testSquareEqualEdgesBiggerThanMax() throws {
        let maxLength = 50
        let image = createImage(size: .init(width: 96.0, height: 96.0))
        let squareImage = try XCTUnwrap(image.squared(maxSize: .pixels(maxLength)))
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, CGFloat(maxLength))
        XCTAssertEqual(squareImage.size.height * squareImage.scale, CGFloat(maxLength))
    }

    @MainActor
    func testSquareEqualEdgesSmallerThanMax() throws {
        let image = createImage(size: .init(width: 96.1, height: 96.1))
        let squareImage = try XCTUnwrap(image.squared(maxSize: .pixels(1024)))
        let targetLength = min(image.size.width * image.scale, image.size.height * image.scale)
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, targetLength)
        XCTAssertEqual(squareImage.size.height * squareImage.scale, targetLength)
    }

    @MainActor
    func testSquareUnequalEdgesBiggerThanMaxWithScale2() throws {
        let targetScale: CGFloat = 2.0
        let maxLength = 50
        let image = createImage(size: .init(width: 96.1, height: 96.0), scale: targetScale)
        let squareImage = try XCTUnwrap(image.squared(maxSize: .pixels(maxLength)))
        XCTAssertEqual(squareImage.scale, targetScale)
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, CGFloat(maxLength))
        XCTAssertEqual(squareImage.size.height * squareImage.scale, CGFloat(maxLength))
    }

    private func createImage(color: UIColor = .blue, size: CGSize, scale: CGFloat = 1) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
