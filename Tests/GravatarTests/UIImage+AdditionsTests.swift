import Testing
import UIKit

@testable import Gravatar

enum UIImageAdditionsTests {
    @Suite("isSquare")
    struct IsSquareTests {
        @Test("Square image")
        func testIsSquareForSquareImage() {
            // Given
            let squareImage = createImage(width: 100, height: 100)

            // When
            let isSquare = squareImage.isSquare

            // Then
            #expect(isSquare)
        }

        @Test("Non-square images", arguments: TestImage.nonSquareImages)
        func testIsSquareForNonSquarePortraitImage(testImage: TestImage) {
            // Given
            let nonSquareImage = testImage.image

            // When
            let isSquare = nonSquareImage.isSquare

            // Then
            #expect(!isSquare)
        }
    }

    @Suite("Squareness")
    struct SquardnessTests {
        @Test("Squareness: Square image")
        func testSquarenessForSquareImage() {
            // Given
            let squareImage = createImage(width: 100, height: 100)

            // When
            let squareness = squareImage.squareness

            // Then
            #expect(squareness == 1.0)
        }

        @Test("Squareness: Non-square images", arguments: TestImage.nonSquareImages)
        func testSquarenessForNonSquarePortraitImage(testImage: TestImage) {
            // Given
            let nonSquareImage = testImage.image

            // When
            let squareness = nonSquareImage.squareness

            // Then
            #expect(squareness == 0.5)
        }

        @Test("Squareness: Negative CGSize returns positive squareness")
        func negativeSquarenessReturnsNonNegativeSquareness() {
            // Given a CGSize that is not square with one negative value
            let size = CGSize(width: -100, height: 99)

            // And an image created using that size
            let image = createImage(size: size)

            // When
            let squareness = image.squareness

            // Then the UIImage should have size `CGSize.zero` and the squareness should be `1.0`
            #expect(image.size == .zero)
            #expect(squareness == 1.0)
        }
    }

    @Suite("ShortEdge")
    struct ShortEdgeTests {
        @Test("Square image")
        func shortEdgeForSquareImage() {
            // Given
            let squareImage = createImage(width: 150, height: 150)

            // When
            let shortEdge = squareImage.shortEdge

            // Then
            #expect(shortEdge == 150)
        }

        @Test("Non-square images", arguments: TestImage.nonSquareImages)
        func shortEdgeForPortraitImage(testImage: TestImage) {
            // Given
            let nonSquareImage = testImage.image

            // When
            let shortEdge = nonSquareImage.shortEdge

            // Then
            #expect(shortEdge == 150)
        }
    }

    @Suite("LongEdge")
    struct LongEdgeTests {
        @Test("Square image")
        func longEdgeForSquareImage() {
            // Given
            let nonSquareImage = createImage(width: 150, height: 150)

            // When
            let longEdge = nonSquareImage.longEdge

            // Then
            #expect(longEdge == 150)
        }

        @Test("Non-square images", arguments: TestImage.nonSquareImages)
        func longEdgeForPortraitImage(testImage: TestImage) {
            // Given
            let nonSquareImage = testImage.image

            // When
            let longEdge = nonSquareImage.longEdge

            // Then
            #expect(longEdge == 300)
        }
    }
}

// MARK: - Helpers

private func createImage(width: CGFloat, height: CGFloat, scale: CGFloat = 1, fillColor: UIColor = .red) -> UIImage {
    assert(scale > 0)

    return createImage(
        size: CGSize(width: width / scale, height: height / scale),
        scale: scale,
        fillColor: fillColor
    )
}

private func createImage(size: CGSize, scale: CGFloat = 1, fillColor: UIColor = .red) -> UIImage {
    assert(scale > 0)

    let format = UIGraphicsImageRendererFormat()
    format.scale = scale
    return UIGraphicsImageRenderer(size: size, format: format).image { context in
        fillColor.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}

struct TestImage {
    static let nonSquareImages: [TestImage] = [.portrait, .landscaope]
    static let portrait: TestImage = .init(width: 150, height: 300)
    static let landscaope: TestImage = .init(width: 300, height: 150)

    let width: CGFloat
    let height: CGFloat

    var image: UIImage {
        createImage(width: width, height: height)
    }
}
