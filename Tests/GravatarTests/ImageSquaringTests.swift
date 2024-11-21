import Testing
import UIKit

@testable import Gravatar

@Suite("Image Squaring")
struct ImageSquaringTests {
    @Suite("Default Squareness")
    struct DefaultSquarenessThresholdTests {
        @Test("Square image is not modified")
        func squareImage() async throws {
            // Given a square image
            let squareImage = createImage(width: 100, height: 100)

            // When the default squaring is applied
            let result = squareImage.squared()

            // Then it should remain unchanged
            #expect(result == squareImage, "UIImage objects should be identical")
        }

        @Test("Squareness above threshold is squared")
        func imageWithSquarenessAboveThresholdIsSquareded() {
            // Given an image with a minor size difference (98x100) with a squareness (`0.98`)
            // at or above the default squarenessThreshold (`0.98`)
            let slightDifferenceImage = createImage(width: 98, height: 100)

            // Squaring applied with the default tolerance
            let result = slightDifferenceImage.squared()

            // Then the result should aspect-fill and become 99x99
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width == 98, "Width should match the smaller side")
            #expect(result.size.height == 98, "Height should match the smaller side")
        }

        @Test("Squareness below threshold is unchanged")
        func imageWithSquarenessBelowThresholdIsUnchanged() {
            // Given an image with a minor size difference (97x100) where a squareness (`0.97`)
            // is below the default squarenessTolerance (`0.98`)
            let slightDifferenceImage = createImage(width: 97, height: 100)

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared()

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }
    }

    // MARK: - Very Small Imgae Tests

    @Suite("Very Small Images")
    struct VerySmallImageSquarenessToleranceTests {
        @Test("Non-square image is unchanged")
        func verySmallNonSquareImageIsUnchanged() {
            // Given a very small, non-square image (1x2) below the default squarenessThreshold
            let smallImage = createImage(width: 1, height: 2)

            // When the default squaring is applied
            let result = smallImage.squared()

            // Then the image should be unchanged
            #expect(result == smallImage, "Image should be unchanged")
        }

        @Test("Non-square image is squared")
        func verySmallNonSquareImageIsSquared() {
            // Given a very small, non-square image (1x2)
            let smallImage = createImage(width: 1, height: 2)

            // When squaring is applied with a very low squaringThreshold
            let result = smallImage.squared(aboveThreshold: 0.0)

            // Then the image should be squared to 1x1
            #expect(result.isSquare, "Image should be squared")
            #expect(result.size.width == 1, "Width should be 1")
            #expect(result.size.height == 1, "Height should be 1")
        }

        @Test("Square image is unchanged")
        func verySmallSquareImage() {
            // Given a very small, square image (1x1) below the default squarenessThreshold
            let smallImage = createImage(width: 1, height: 1)

            // When the default squaring is applied
            let result = smallImage.squared()

            // Then the image should be unchanged
            #expect(result == smallImage, "Image should be unchanged")
        }

        @Test("Zero size image remains unchanged")
        func zeroSizeImage() {
            // Given an image with zero size (0x0)
            let zeroSizeImage = createImage(width: 0, height: 0)

            // When the default squaring is applied
            let result = zeroSizeImage.squared()

            // Then the result should be a 0x0 square image
            #expect(result == zeroSizeImage, "Image should remain unchanged")
        }
    }

    // MARK: - Custom Squareness Threshold

    @Suite("Custom Squareness Threshold")
    struct CustomSquarenessThresholdTests {
        @Test("Squareness above threshold is squared")
        func imageSquarenessAboveThresholdIsSquareded() {
            // Given an image with a minor size difference (100x103) where the squareness (`0.9709`)
            // is at or above a custom squarenessThreshold (`0.97`)
            let slightDifferenceImage = createImage(width: 100, height: 103)
            let squarenessThreshold: CGFloat = 0.97

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(aboveThreshold: squarenessThreshold)

            // Then the result should aspect-fill and become 100x100
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width == 100, "Width should match the smaller side")
            #expect(result.size.height == 100, "Height should match the smaller side")
        }

        @Test("Squareness below threshold is untouched")
        func imageSquarenessBelowThresholdIsSquareded() {
            // Given an image with a minor size difference (100x104) where the squareness (`0.9616`)
            // is below a custom squarenessThreshold (`0.97`)
            let slightDifferenceImage = createImage(width: 100, height: 104)
            let squarenessThreshold: CGFloat = 0.97

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(aboveThreshold: squarenessThreshold)

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }
    }

    // MARK: - Scale Test

    @Test("Squared image retains image scale")
    func imageSquaringWithScale2x() {
        // Given a retina image (@2x) with size 302x300
        let scale: CGFloat = 2.0
        let image = createImage(width: 302, height: 300, scale: scale)

        // When the default squaring is applied
        let result = image.squared()

        // Then the result should be a 500x500 square image with scale @2x
        #expect(result.isSquare, "Image should be square")
        #expect(result.size.width == 300 / scale, "Width should match the shorter side")
        #expect(result.size.height == 300 / scale, "Height should match the shorter side")
        #expect(result.scale == scale, "Image scale should remain @2x")
    }
}

// MARK: - Helpers

private func createImage(width: CGFloat, height: CGFloat, scale: CGFloat = 1, fillColor: UIColor = .red) -> UIImage {
    assert(scale > 0)

    let size = CGSize(width: width / scale, height: height / scale)
    let format = UIGraphicsImageRendererFormat()
    format.scale = scale
    return UIGraphicsImageRenderer(size: size, format: format).image { context in
        fillColor.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
}
