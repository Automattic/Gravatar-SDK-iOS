import Testing
import UIKit

@testable import Gravatar

struct ImageSquaringTests {
    @Test("Square image is not modified")
    func squareImage() async throws {
        // Given a square image
        let squareImage = createImage(width: 100, height: 100)

        // When the default squaring is applied
        let result = squareImage.squared()

        // Then it should remain unchanged
        #expect(result == squareImage, "UIImage objects should be identical")
    }

    @Test("Tall image is squared")
    func tallImageIsSquared() {
        // Given an extremely wide image (10_000x500)
        let wideImage = createImage(width: 9999, height: 10000)

        // When the default squaring is applied
        let result = wideImage.squared(maxSize: .pixels(100))

        // Then the result should be a 100x100 square image
        // Assumes scale == 1 (pixels == points)
        #expect(result.isSquare, "Image should be squared")
        #expect(result.size.width == 100, "Width should be 100")
        #expect(result.size.height == 100, "Height should be 100")
    }

    @Test("Wide image is squared")
    func wideImageIsSquared() {
        // Given an extremely wide image (10_000x500)
        let wideImage = createImage(width: 10000, height: 9999)

        // When the default squaring is applied
        let result = wideImage.squared(maxSize: .pixels(100))

        // Then the result should be a 100x100 square image
        // Assumes scale == 1 (pixels == points)
        #expect(result.isSquare, "Image should be squared")
        #expect(result.size.width == 100, "Width should be 100")
        #expect(result.size.height == 100, "Height should be 100")
    }

    // MARK: - Very Small Imgae Tests

    @Test("Very small non-square image is unchanged")
    func verySmallNonSquareImage() {
        // Given a very small, non-square image (1x2) outside the default squareness tolerance
        let smallImage = createImage(width: 1, height: 2)

        // When the default squaring is applied
        let result = smallImage.squared(maxSize: .pixels(2))

        // Then the image should be unchanged
        #expect(result == smallImage, "Image should be unchanged")
    }

    @Test("Very small non-square image is squared")
    func verySmallNonSquareImageIsSquared() {
        // Given a very small, non-square image (1x2)
        let smallImage = createImage(width: 1, height: 2)

        // When squaring is applied with a very large squaring tolerance
        let result = smallImage.squared(withinTolerance: 1.0)

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

    // MARK: - Max Size Tests

    @Test("Image above max size is reduced and squared")
    func imageAboveMaxSizeIsReducedSquared() {
        // Given an extremely wide image (10_000x500)
        let wideImage = createImage(width: 10000, height: 9999)

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
        // Given an extremely wide image (10_000x500)
        let wideImage = createImage(width: 10000, height: 500)

        // When the default squaring is applied
        let result = wideImage.squared(maxSize: .pixels(100))

        // Then the result should be a 100x5 square image
        // Assumes scale == 1 (pixels == points)
        #expect(!result.isSquare, "Image should no be squared")
        #expect(result.size.width == 100, "Width should be maxSize")
        #expect(result.size.height == 5, "Height should be 100/10_000 the original height")
    }

    @Test("Image with height above max size is reduced and not squared")
    func imageHeightAboveMaxSizeIsReducedNotSquared() {
        // Given an extremely wide image (10_000x500)
        let tallImage = createImage(width: 500, height: 10000)

        // When the default squaring is applied
        let result = tallImage.squared(maxSize: .pixels(100))

        // Then the result should be a 5x100 square image
        // Assumes scale == 1 (pixels == points)
        #expect(!result.isSquare, "Image should no be squared")
        #expect(result.size.width == 5, "Width should be maxSize")
        #expect(result.size.height == 100, "Height should be 100/10_000 the original height")
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

    @Suite("Default Squareness Tolerance")
    struct DefaultSquarenessToleranceTests {
        @Test("Squareness within tolerance is squared")
        func imageWithDeviationFromSquareWithinToleranceIsSquareded() {
            // Given an image with a minor size difference (100x102) where the edge ratio (`0.9804`)
            // is above the custom squareness (`0.97`)
            let slightDifferenceImage = createImage(width: 100, height: 102)
            let deviationFromSquareTolerance: CGFloat = 0.03

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(withinTolerance: deviationFromSquareTolerance)

            // Then the result should aspect-fill and become 100x100
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width == 100, "Width should match the smaller side")
            #expect(result.size.height == 100, "Height should match the smaller side")
        }

        @Test("Squareness outside of tolerance is untouched")
        func imageWithDeviationFromSquareOutsideOfToleranceIsSquareded() {
            // Given an image with a minor size difference (100x104) where the edge ratio (`0.9615`)
            // is below the custom squareness (`0.97`)
            let slightDifferenceImage = createImage(width: 100, height: 104)
            let deviationFromSquareTolerance: CGFloat = 0.03

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(withinTolerance: deviationFromSquareTolerance)

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }
    }

    // MARK: - Custom Squareness Tolerance

    @Suite("Custom Squareness Tolerance")
    struct CustomSquarenessToleranceTests {
        @Test("Squareness within tolerance is squared")
        func imageWithDeviationFromSquareWithinToleranceIsSquareded() {
            // Given an image with a minor size difference (100x102) where the edge ratio (`0.9804`)
            // is above the custom squareness (`0.97`)
            let slightDifferenceImage = createImage(width: 100, height: 102)
            let deviationFromSquareTolerance: CGFloat = 0.03

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(withinTolerance: deviationFromSquareTolerance)

            // Then the result should aspect-fill and become 100x100
            // Assumes scale == 1 (pixels == points)
            #expect(result.isSquare, "Image should be square")
            #expect(result.size.width == 100, "Width should match the smaller side")
            #expect(result.size.height == 100, "Height should match the smaller side")
        }

        @Test("Squareness outside of tolerance is untouched")
        func imageWithDeviationFromSquareOutsideOfToleranceIsSquareded() {
            // Given an image with a minor size difference (100x104) where the edge ratio (`0.9615`)
            // is below the custom squareness (`0.97`)
            let slightDifferenceImage = createImage(width: 100, height: 104)
            let deviationFromSquareTolerance: CGFloat = 0.03

            // Squaring applied with custom tolerance
            let result = slightDifferenceImage.squared(withinTolerance: deviationFromSquareTolerance)

            // Then the image should be unchanged
            #expect(result == slightDifferenceImage, "Image should be unchanged")
        }
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
