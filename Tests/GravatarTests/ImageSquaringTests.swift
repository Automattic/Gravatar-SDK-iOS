import Testing
import UIKit

@testable import Gravatar

struct ImageSquaringTests {
    @Suite("Default Squareness")
    struct DefaultSquarenessToleranceTests {
        @Test("Square image is not modified")
        func squareImage() async throws {
            // Given a square image
            let squareImage = createImage(width: 100, height: 100)

            // When the default squaring is applied
            let result = squareImage.squared()

            // Then it should remain unchanged
            #expect(result == squareImage, "UIImage objects should be identical")
        }

        @Test("Squareness within tolerance is squared")
        func imageWithDeviationFromSquareWithinToleranceIsSquareded() {
            // Given an image with a minor size difference (100x102) where the divergence from square (`0.019`)
            // is within the default squarenessTolerance (`0.02`)
            let slightDifferenceImage = createImage(width: 100, height: 102)

            // Squaring applied with the default tolerance
            let result = slightDifferenceImage.squared()

            // Then the result should aspect-fill and become 100x100
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width == 100, "Width should match the smaller side")
            #expect(result.size.height == 100, "Height should match the smaller side")
        }

        @Test("Squareness outside of tolerance is untouched")
        func imageWithDeviationFromSquareOutsideOfToleranceIsSquareded() {
            // Given an image with a minor size difference (100x103) where the divergence from square (`0.029`)
            // is outside the default squarenessTolerance (`0.02`)
            let slightDifferenceImage = createImage(width: 100, height: 103)

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared()

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }
    }

    // MARK: - Very Small Imgae Tests

    @Suite("Very Small Images")
    struct VerySmallImageSquarenessToleranceTests {
        @Test("Very small non-square image is unchanged")
        func verySmallNonSquareImage() {
            // Given a very small, non-square image (1x2) outside the default squareness tolerance
            let smallImage = createImage(width: 1, height: 2)

            // When the default squaring is applied
            let result = smallImage.squared()

            // Then the image should be unchanged
            #expect(result == smallImage, "Image should be unchanged")
        }

        @Test("Very small non-square image is squared")
        func verySmallNonSquareImageIsSquared() {
            // Given a very small, non-square image (1x2)
            let smallImage = createImage(width: 1, height: 2)

            // When squaring is applied with a very large squaring tolerance
            let result = smallImage.squared(aboveThreshold: 1.0)

            // Then the image should be squared to 1x1
            #expect(result.isSquare, "Image should be squared")
            #expect(result.size.width == 1, "Width should be 1")
            #expect(result.size.height == 1, "Height should be 1")
        }

        @Test("Very small square image is unchanged")
        func verySmallSquareImage() {
            // Given a very small, square image (1x1) outside the default squareness tolerance
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

    // MARK: - Max Size Tests

    @Suite("Max Size")
    struct MaxSizeTests {
        @Test("Image is not reduced when max size is `nil`")
        func squareImageIsNotReducedWhenMaxSizeIsNil() {
            // Given a very large square image (10_000x10_000)
            let largeImage = createImage(width: 10000, height: 10000)

            // When maxSize is set to nil
            let result = largeImage.squared(maxSize: nil)

            // Then the result should be unchangeed
            #expect(result == largeImage, "Image should be unchanged")
        }

        @Test("Tall image is reduced and squared")
        func tallImageIsSquared() {
            // Given a tall image (9_801x10_000)
            let wideImage = createImage(width: 9801, height: 10000)

            // When the default squaring is applied
            let result = wideImage.squared(maxSize: .pixels(100))

            // Then the result should be a 100x100 square image
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be squared")
            #expect(result.size.width == 100, "Width should be 100")
            #expect(result.size.height == 100, "Height should be 100")
        }

        @Test("Wide image is reduced squared")
        func wideImageIsSquared() {
            // Given an extremely wide image (10_000x9_801)
            let wideImage = createImage(width: 10000, height: 9801)

            // When the default squaring is applied
            let result = wideImage.squared(maxSize: .pixels(100))

            // Then the result should be a 100x100 square image
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be squared")
            #expect(result.size.width == 100, "Width should be 100")
            #expect(result.size.height == 100, "Height should be 100")
        }

        @Test("Image with width above max size is reduced and not squared")
        func imageWidthAboveMaxSizeIsReducedNotSquared() {
            // Given an extremely wide image (10_000x100)
            let wideImage = createImage(width: 10000, height: 100)

            // When the default squaring is applied
            let result = wideImage.squared(maxSize: .pixels(100))

            // Then the result should be a 100x1 square image
            // Assumes scale == 1 (pixels == points)
            #expect(!result.isSquare, "Image should no be squared")
            #expect(result.size.width == 100, "Width should be maxSize")
            #expect(result.size.height == 1, "Height should be 100/10_000 the original height")
        }

        @Test("Image with height above max size is reduced and not squared")
        func imageHeightAboveMaxSizeIsReducedNotSquared() {
            // Given an extremely wide image (10_000x100)
            let tallImage = createImage(width: 100, height: 10000)

            // When the default squaring is applied
            let result = tallImage.squared(maxSize: .pixels(100))

            // Then the result should be a 1x100 square image
            // Assumes scale == 1 (pixels == points)
            #expect(!result.isSquare, "Image should no be squared")
            #expect(result.size.width == 1, "Width should be maxSize")
            #expect(result.size.height == 100, "Height should be 100/10_000 the original height")
        }
    }

    // MARK: - Custom Squareness Tolerance

    @Suite("Custom Squareness Tolerance")
    struct CustomSquarenessToleranceTests {
        @Test("Squareness within tolerance is squared")
        func imageWithDeviationFromSquareWithinToleranceIsSquareded() {
            // Given an image with a minor size difference (100x103) where the divergence from square (`0.029`)
            // is within the default squarenessTolerance (`0.03`)
            let slightDifferenceImage = createImage(width: 100, height: 103)
            let deviationFromSquareTolerance: CGFloat = 0.03

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(aboveThreshold: deviationFromSquareTolerance)

            // Then the result should aspect-fill and become 100x100
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width == 100, "Width should match the smaller side")
            #expect(result.size.height == 100, "Height should match the smaller side")
        }

        @Test("Squareness outside of tolerance is untouched")
        func imageWithDeviationFromSquareOutsideOfToleranceIsSquareded() {
            // Given an image with a minor size difference (100x104) where the divergence from square (`0.0385`)
            // is within the custom squarenessTolerance (`0.03`)
            let slightDifferenceImage = createImage(width: 100, height: 104)
            let deviationFromSquareTolerance: CGFloat = 0.03

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(aboveThreshold: deviationFromSquareTolerance)

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }

        @Test("Negative squareness tolerance is treated as 0 tolerance")
        func negativeSquarenessToleranceIsTreatedAsZeroTolerance() {
            // Given an image with a very small deviation from square
            let slightDifferenceImage = createImage(width: 100_000, height: 100_001)

            // Squaring the image using a negative tolerance
            let result = slightDifferenceImage.squared(aboveThreshold: -1.0)

            // Then the image should be unchanged, as though the tolerance were 0
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }

        @Test("Squareness tolerance above 1 is treated as a tolerance of 1")
        func squarenessToleranceAboveOneIsTreatedAsZeroTolerance() {
            // Given an image with a very large deviation from square
            let slightDifferenceImage = createImage(width: 100_000, height: 1)

            // Squaring the image using a tolerance above 1
            let result = slightDifferenceImage.squared(aboveThreshold: 10.0)

            // Then the image should be squared, as though the tolerance were 1
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width == 1, "Image should be 1 pixels wide")
            #expect(result.size.height == 1, "Image should be 1 pixels tall")
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
