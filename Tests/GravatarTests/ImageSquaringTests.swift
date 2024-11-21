import Testing
import UIKit

@testable import Gravatar

@Suite("Image Squaring")
struct ImageSquaringTests {
    @Suite("Default Squareness")
    struct DefaultSquarenessThresholdTests {
        @Test("Square image is not modified", arguments: ScaleFactor.allCases)
        func squareImage(at scaleFactor: ScaleFactor) async throws {
            // Given a square image
            let squareImage = createImage(widthInPixels: 100, heightInPixels: 100, scale: scaleFactor.scale)

            // When the default squaring is applied
            let result = squareImage.squared()

            // Then it should remain unchanged
            #expect(result == squareImage, "UIImage objects should be identical")
        }

        @Test("Squareness above threshold is squared", arguments: ScaleFactor.allCases)
        func imageWithSquarenessAboveThresholdIsSquareded(at scaleFactor: ScaleFactor) {
            // Given an image with a minor size difference (99x100) with a squareness (`0.99`)
            // at or above the default squarenessThreshold (`0.98`)
            let slightDifferenceImage = createImage(widthInPixels: 99, heightInPixels: 100, scale: scaleFactor.scale)

            // Squaring applied with the default tolerance
            let result = slightDifferenceImage.squared()

            // Then the result should aspect-fill and become 99x99
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width * result.scale == 99, "Width should match the smaller side")
            #expect(result.size.height * result.scale == 99, "Height should match the smaller side")
        }

        @Test("Squareness below threshold is unchanged", arguments: ScaleFactor.allCases)
        func imageWithSquarenessBelowThresholdIsUnchanged(at scaleFactor: ScaleFactor) {
            // Given an image with a minor size difference (97x100) where a squareness (`0.97`)
            // is below the default squarenessTolerance (`0.98`)
            let slightDifferenceImage = createImage(widthInPixels: 97, heightInPixels: 100, scale: scaleFactor.scale)

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared()

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }

        @Test(
            "Non-square images use shortest side at all scales",
            arguments: [
                ImageSpec(pixelWidth: 2003, pixelHeight: 2002), // w: 1001.5 pt x 1001 pt @2.0
                ImageSpec(pixelWidth: 3004, pixelHeight: 3003) // w: 1001.333 pt x 1001 pt @3.0
            ],
            ScaleFactor.allCases
        )
        func nonSquareImagesUseShortestSideAtAllScales(imageSpec: ImageSpec, scaleFactor: ScaleFactor) throws {
            // Given a non-square image where at least one side will result in a fractional point at a given scale
            let image = createImage(widthInPixels: CGFloat(imageSpec.pixelWidth), heightInPixels: CGFloat(imageSpec.pixelHeight), scale: scaleFactor.scale)
            try #require(!image.isSquare, "The generated image must not be square")

            // When the default squaring is applied
            let result = image.squared()

            // The result should be square, and both dimensions should match the shortest side
            let shortestSideInPixels = min(
                image.size.width * image.scale,
                image.size.height * image.scale
            )

            let resultWidthInPixels = result.size.width * result.scale
            let resultHeightInPixels = result.size.height * result.scale

            #expect(result.isSquare, "Image should be square")
            #expect(resultWidthInPixels == shortestSideInPixels, "Width should match shortest side")
            #expect(resultHeightInPixels == shortestSideInPixels, "Height should match shortest side")
        }
    }

    // MARK: - Very Small Imgae Tests

    @Suite("Very Small Images")
    struct VerySmallImageSquarenessToleranceTests {
        @Test("Non-square image is unchanged", arguments: ScaleFactor.allCases)
        func verySmallNonSquareImageIsUnchanged(at scaleFactor: ScaleFactor) {
            // Given a very small, non-square image (1x2) below the default squarenessThreshold
            let smallImage = createImage(widthInPixels: 1, heightInPixels: 2, scale: scaleFactor.scale)

            // When the default squaring is applied
            let result = smallImage.squared()

            // Then the image should be unchanged
            #expect(result == smallImage, "Image should be unchanged")
        }

        @Test("Non-square image is squared", arguments: ScaleFactor.allCases)
        func verySmallNonSquareImageIsSquared(at scaleFactor: ScaleFactor) {
            // Given a very small, non-square image (1x2)
            // Test requires `scale = 1`
            let smallImage = createImage(widthInPixels: 1, heightInPixels: 2, scale: scaleFactor.scale)

            // When squaring is applied with a very low squaringThreshold
            let result = smallImage.squared(aboveThreshold: 0.0)

            // Then the image should be squared to 1x1
            #expect(result.isSquare, "Image should be squared")
            #expect(result.size.width * result.scale == 1, "Width should be 1")
            #expect(result.size.height * result.scale == 1, "Height should be 1")
        }

        @Test("Square image is unchanged", arguments: ScaleFactor.allCases)
        func verySmallSquareImage(at scaleFactor: ScaleFactor) {
            // Given a very small, square image (1x1) below the default squarenessThreshold
            let smallImage = createImage(widthInPixels: 1, heightInPixels: 1, scale: scaleFactor.scale)

            // When the default squaring is applied
            let result = smallImage.squared()

            // Then the image should be unchanged
            #expect(result == smallImage, "Image should be unchanged")
        }

        @Test("Zero size image remains unchanged", arguments: ScaleFactor.allCases)
        func zeroSizeImage(at scaleFactor: ScaleFactor) {
            // Given an image with zero size (0x0)
            let zeroSizeImage = createImage(widthInPixels: 0, heightInPixels: 0, scale: scaleFactor.scale)

            // When the default squaring is applied
            let result = zeroSizeImage.squared()

            // Then the result should be a 0x0 square image
            #expect(result == zeroSizeImage, "Image should remain unchanged")
        }
    }

    // MARK: - Custom Squareness Threshold

    @Suite("Custom Squareness Threshold")
    struct CustomSquarenessThresholdTests {
        @Test("Squareness above threshold is squared", arguments: ScaleFactor.allCases)
        func imageSquarenessAboveThresholdIsSquareded(at scaleFactor: ScaleFactor) {
            // Given an image with a minor size difference (100x103) where the squareness (`0.9709`)
            // is at or above a custom squarenessThreshold (`0.97`)
            let slightDifferenceImage = createImage(widthInPixels: 100, heightInPixels: 103, scale: scaleFactor.scale)
            let squarenessThreshold: CGFloat = 0.97

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(aboveThreshold: squarenessThreshold)

            // Then the result should aspect-fill and become 100x100
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width * result.scale == 100, "Width should match the smaller side")
            #expect(result.size.height * result.scale == 100, "Height should match the smaller side")
        }

        @Test("Squareness below threshold is untouched", arguments: ScaleFactor.allCases)
        func imageSquarenessBelowThresholdIsSquareded(at scaleFactor: ScaleFactor) {
            // Given an image with a minor size difference (100x104) where the squareness (`0.9616`)
            // is below a custom squarenessThreshold (`0.97`)
            let slightDifferenceImage = createImage(widthInPixels: 100, heightInPixels: 104, scale: scaleFactor.scale)
            let squarenessThreshold: CGFloat = 0.97

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(aboveThreshold: squarenessThreshold)

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }
    }
}

// MARK: - Helpers

func createImage(
    widthInPixels: CGFloat,
    heightInPixels: CGFloat,
    scale: CGFloat,
    fillColor: UIColor = .red
) -> UIImage {
    assert(scale > 0)

    return createImage(
        size: CGSize(width: widthInPixels / scale, height: heightInPixels / scale),
        scale: scale,
        fillColor: fillColor
    )
}

func createImage(size: CGSize, scale: CGFloat, fillColor: UIColor = .red) -> UIImage {
    assert(scale > 0)

    let format = UIGraphicsImageRendererFormat()
    format.scale = scale

    return UIGraphicsImageRenderer(size: size, format: format).image { context in
        fillColor.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}

struct ImageSpec: CustomTestStringConvertible {
    let pixelWidth: Int
    let pixelHeight: Int

    var testDescription: String {
        "w: \(pixelWidth) px x h: \(pixelHeight) px"
    }
}
