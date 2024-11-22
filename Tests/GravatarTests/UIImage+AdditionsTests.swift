import Testing
import UIKit

@testable import Gravatar

@Suite("UIImage+Additions")
struct UIImageAdditionsTests {
    @Suite("isSquare")
    struct IsSquareTests {
        @Test("Square image", arguments: ScaleFactor.allCases)
        func squareImage(at scaleFactor: ScaleFactor) {
            // Given
            let squareImage = createImage(widthInPixels: 100, heightInPixels: 100, scale: scaleFactor.scale)

            // When
            let isSquare = squareImage.isSquare

            // Then
            #expect(isSquare)
        }

        @Test("Non-square images", arguments: TestImage.nonSquareImages, ScaleFactor.allCases)
        func nonSquareImage(testImage: TestImage, scaleFactor: ScaleFactor) {
            // Given
            let nonSquareImage = testImage.image(atScale: scaleFactor.scale)

            // When
            let isSquare = nonSquareImage.isSquare

            // Then
            #expect(!isSquare)
        }
    }

    @Suite("Squareness")
    struct SquarenessTests {
        @Test("Square image", arguments: ScaleFactor.allCases)
        func squareImageHasSquarenessOne(at scaleFactor: ScaleFactor) {
            // Given
            let squareImage = createImage(widthInPixels: 100, heightInPixels: 100, scale: scaleFactor.scale)

            // When
            let squareness = squareImage.squareness

            // Then
            #expect(squareness == 1.0)
        }

        @Test("Non-square images", arguments: TestImage.nonSquareImages, ScaleFactor.allCases)
        func nonSquareImageHasSquarenessHalf(testImage: TestImage, scaleFactor: ScaleFactor) {
            // Given
            let nonSquareImage = testImage.image(atScale: scaleFactor.scale)

            // When
            let squareness = nonSquareImage.squareness

            // Then

            #expect(squareness == testImage.expectedSquareness)
        }

        @Test("Negative CGSize returns positive squareness", arguments: ScaleFactor.allCases)
        func negativeSquarenessReturnsNonNegativeSquareness(at scaleFactor: ScaleFactor) {
            // Given a CGSize that is not square with one negative value
            let size = CGSize(width: -100, height: 99)

            // And an image created using that size
            let image = createImage(size: size, scale: scaleFactor.scale)

            // When
            let squareness = image.squareness

            // Then the UIImage should have size `CGSize.zero` and the squareness should be `1.0`
            #expect(image.size == .zero)
            #expect(squareness == 1.0)
        }
    }

    @Suite("ShortEdge")
    struct ShortEdgeTests {
        @Test("Square image", arguments: ScaleFactor.allCases)
        func shortEdgeForSquareImage(at scaleFactor: ScaleFactor) {
            // Given
            let squareImage = createImage(widthInPixels: 150, heightInPixels: 150, scale: scaleFactor.scale)

            // When
            let shortEdge = squareImage.shortEdge

            // Then
            #expect(shortEdge * scaleFactor.scale == 150)
        }

        @Test("Non-square images", arguments: TestImage.nonSquareImages, ScaleFactor.allCases)
        func shortEdgeForPortraitImage(testImage: TestImage, scaleFactor: ScaleFactor) {
            // Given
            let nonSquareImage = testImage.image(atScale: scaleFactor.scale)

            // When
            let shortEdge = nonSquareImage.shortEdge

            // Then
            #expect(shortEdge * scaleFactor.scale == testImage.expectedShortEdge)
        }
    }

    @Suite("LongEdge")
    struct LongEdgeTests {
        @Test("Square image", arguments: ScaleFactor.allCases)
        func longEdgeForSquareImage(at scaleFactor: ScaleFactor) {
            // Given
            let nonSquareImage = createImage(widthInPixels: 150, heightInPixels: 150, scale: scaleFactor.scale)

            // When
            let longEdge = nonSquareImage.longEdge

            // Then
            #expect(longEdge * scaleFactor.scale == 150)
        }

        @Test("Non-square images", arguments: TestImage.nonSquareImages, ScaleFactor.allCases)
        func longEdgeForPortraitImage(testImage: TestImage, scaleFactor: ScaleFactor) {
            // Given
            let nonSquareImage = testImage.image(atScale: scaleFactor.scale)

            // When
            let longEdge = nonSquareImage.longEdge

            // Then
            #expect(longEdge * scaleFactor.scale == testImage.expectedLongEdge)
        }
    }
}

// MARK: - Helpers

struct TestImage: CustomTestStringConvertible {
    static let nonSquareImages: [TestImage] = [.portrait, .landscape, .trickyAtScale3]

    /// A test image with a portrait aspect ratio (`150 x 300`)
    static let portrait: TestImage = .init(
        width: 150,
        height: 300,
        expectedSquareness: 0.5,
        expectedShortEdge: 150,
        expectedLongEdge: 300
    )

    /// A test image with a landscape aspect ratio (`300 x 150`)
    static let landscape: TestImage = .init(
        width: 300,
        height: 150,
        expectedSquareness: 0.5,
        expectedShortEdge: 150,
        expectedLongEdge: 300
    )

    /// A test image with one value that is not divisible by `3` (`98 x 100`)
    static let trickyAtScale3: TestImage = .init(
        width: 98,
        height: 100,
        expectedSquareness: 0.98,
        expectedShortEdge: 98,
        expectedLongEdge: 100
    )

    let width: CGFloat
    let height: CGFloat
    let expectedSquareness: CGFloat?
    let expectedShortEdge: CGFloat?
    let expectedLongEdge: CGFloat?

    init(
        width: CGFloat,
        height: CGFloat,
        expectedSquareness: CGFloat? = nil,
        expectedShortEdge: CGFloat? = nil,
        expectedLongEdge: CGFloat? = nil
    ) {
        self.width = width
        self.height = height
        self.expectedSquareness = expectedSquareness
        self.expectedShortEdge = expectedShortEdge
        self.expectedLongEdge = expectedLongEdge
    }

    func image(atScale scale: CGFloat) -> UIImage {
        createImage(widthInPixels: width, heightInPixels: height, scale: scale)
    }

    var testDescription: String {
        "w: \(width) x h: \(height)"
    }
}
