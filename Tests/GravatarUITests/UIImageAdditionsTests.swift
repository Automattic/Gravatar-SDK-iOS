@testable import GravatarUI
import XCTest

final class UIImageAdditionsTests: XCTestCase {
    @MainActor
    func testSquareUnequalEdgesSmallerThanMax() throws {
        let image = try XCTUnwrap(createImage(size: .init(width: 96.1, height: 96.0)))
        let squareImage = try XCTUnwrap(image.square(maxLength: 1024))
        let targetLength = min(image.size.width * image.scale, image.size.height * image.scale)
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, targetLength)
        XCTAssertEqual(squareImage.size.height * squareImage.scale, targetLength)
    }

    @MainActor
    func testSquareUnequalEdgesBiggerThanMax() throws {
        let maxLength: CGFloat = 50.0
        let image = try XCTUnwrap(createImage(size: .init(width: 96.1, height: 96.0)))
        let squareImage = try XCTUnwrap(image.square(maxLength: maxLength))
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, maxLength)
        XCTAssertEqual(squareImage.size.height * squareImage.scale, maxLength)
    }

    @MainActor
    func testSquareEqualEdgesBiggerThanMax() throws {
        let maxLength: CGFloat = 50.0
        let image = try XCTUnwrap(createImage(size: .init(width: 96.0, height: 96.0)))
        let squareImage = try XCTUnwrap(image.square(maxLength: maxLength))
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, maxLength)
        XCTAssertEqual(squareImage.size.height * squareImage.scale, maxLength)
    }

    @MainActor
    func testSquareEqualEdgesSmallerThanMax() throws {
        let image = try XCTUnwrap(createImage(size: .init(width: 96.1, height: 96.1)))
        let squareImage = try XCTUnwrap(image.square(maxLength: 1024))
        let targetLength = min(image.size.width * image.scale, image.size.height * image.scale)
        XCTAssertEqual(squareImage.size.width, squareImage.size.height)
        XCTAssertEqual(squareImage.size.width * squareImage.scale, targetLength)
        XCTAssertEqual(squareImage.size.height * squareImage.scale, targetLength)
    }

    private func createImage(color: UIColor = .blue, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
