import Testing
import UIKit

@testable import Gravatar

struct ImageSquaringTests {
    @Test
    func squareImage() async throws {
        // Given a square image
        let squareImage = createImage(width: 100, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(squareImage)

        // Then it should remain unchanged
        #expect(result == squareImage, "UIImage objects should be identical")
    }

    @Test
    func portraitImage() {
        // Given a portrait image (50x100)
        let portraitImage = createImage(width: 50, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(portraitImage)

        // Then the result should be a square image (100x100)
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 100, "Width should match the taller side")
        #expect(result.size.height == 100, "Height should match the taller side")
    }

    @Test
    func landscapeImage() {
        // Given a landscape image (200x100)
        let landscapeImage = createImage(width: 200, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(landscapeImage)

        // Then the result should be a square image (200x200)
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 200, "Width should match the wider side")
        #expect(result.size.height == 200, "Height should match the wider side")
    }

    @Test
    func minorAspectDifferenceAboveAspectFillMinSquarenessImageShouldUseAspectFill() {
        // Given an image with a minor size difference (99x100) with a squareness of `0.99`, which is above
        // the default `aspectFillMinSquareness` threshold (`0.98`)
        let slightDifferenceImage = createImage(width: 99, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(slightDifferenceImage)

        // Then the result should aspect-fill and become 99x99
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 99, "Width should match the smaller side")
        #expect(result.size.height == 99, "Height should match the smaller side")
    }

    @Test
    func minorAspectDifferenceMatchesAspectFillMinSquarenessImageShouldUseAspectFill() {
        // Given an image with a minor size difference (98x100) with a squareness of `0.98`, which matches
        // the default `aspectFillMinSquareness` threshold (`0.98`)
        let slightDifferenceImage = createImage(width: 98, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(slightDifferenceImage)

        // Then the result should aspect-fill and become 98x98
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 98, "Width should match the smaller side")
        #expect(result.size.height == 98, "Height should match the smaller side")
    }

    @Test
    func minorAspectDifferenceBelowAspectFillMinSquarenessImageShouldUseAspectFit() {
        // Given an image with a minor size difference (97x100) with a squareness of `0.97`, which is above
        // the default `aspectFillMinSquareness` threshold (`0.98`)
        let slightDifferenceImage = createImage(width: 97, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(slightDifferenceImage)

        // Then the result should aspect-fit and become 100x100
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 100, "Width should match the larger side")
        #expect(result.size.height == 100, "Height should match the larger side")
    }

    // MARK: - Extreme Dimensions Tests

    @Test
    func verySmallImage() {
        // Given a very small image (1x1)
        let smallImage = createImage(width: 1, height: 1)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(smallImage)

        // Then the result should aspect-fit and become 2x2
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 2, "Width should match the larger side")
        #expect(result.size.height == 2, "Height should match the larger side")
    }

    @Test
    func wideImage() {
        // Given an extremely wide image (10_000x500)
        let wideImage = createImage(width: 10000, height: 500)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(wideImage)

        // Then the result should be a 10_000x10_000 square image
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 10000, "Width should match the wider side")
        #expect(result.size.height == 10000, "Height should match the wider side")
    }

    @Test
    func tallImage() {
        // Given an extremely tall image (500x10_000)
        let tallImage = createImage(width: 500, height: 10000)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(tallImage)

        // Then the result should be a 10_000x10_000 square image
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 10000, "Width should match the taller side")
        #expect(result.size.height == 10000, "Height should match the taller side")
    }

    @Test
    func zeroSizeImage() {
        // Given an image with zero size (0x0)
        let zeroSizeImage = createImage(width: 0, height: 0)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(zeroSizeImage)

        // Then the result should be a 0x0 square image
        #expect(result == zeroSizeImage, "Image should remain unchanged")
    }

    // MARK: - Scale Test

    @Test
    func imageSquaringWithScale2x() {
        // Given a retina image (@2x) with size 300x500
        let image = createImage(width: 300, height: 500, scale: 2.0)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(image)

        // Then the result should be a 500x500 square image with scale @2x
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 500, "Width should match the longer side")
        #expect(result.size.height == 500, "Height should match the longer side")
        #expect(result.scale == 2.0, "Image scale should remain @2x")
    }

    // MARK: - Background Color Tests

    @Test
    func backgroundColorIsApplied() throws {
        // Given a non-square image (300x500)
        let image = createImage(width: 300, height: 500, scale: 1, fillColor: .red)

        // And a reference image
        let referenceImage = try #require(
            UIImage(named: "ImageSquaringDefaultBackgroundReferenceImage", in: .module, with: nil)
        ).pngData()

        // When the default squaring strategy is applied
        let resultImage = SquaringStrategy.default.square(image)

        // Then the result should be square
        #expect(resultImage.isSquare(), "The image should be square.")

        // And the generated image should match the reference image
        #expect(resultImage.pngData() == referenceImage)
    }

    // MARK: - Custom Squareness Threshold

    @Test
    func minorAspectDifferenceAboveCustomEdgeRatioThresholdImageShouldUseAspectFill() {
        // Given an image with a minor size difference (100x102) where the edge ratio (`0.9804`)
        // is above the custom squareness (`0.97`)
        let slightDifferenceImage = createImage(width: 100, height: 102)
        let aspectFillMinSquareness: CGFloat = 0.97

        // When the custom squaring function is applied
        let result = SquaringStrategy.squarenessDeterminesFitOrFill(aspectFillMinSquareness: aspectFillMinSquareness).square(slightDifferenceImage)

        // Then the result should aspect-fill and become 100x100
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 100, "Width should match the smaller side")
        #expect(result.size.height == 100, "Height should match the smaller side")
    }

    @Test
    func minorAspectDifferenceBelowCustomEdgeRatioThresholdImageShouldUseAspectFit() {
        // Given an image with a minor size difference (100x104) where the edge ratio (`0.9615`)
        // is below the custom squareness (`0.97`)
        let slightDifferenceImage = createImage(width: 100, height: 104)
        let aspectFillMinSquareness: CGFloat = 0.97

        // When the custom squaring function is applied
        let result = SquaringStrategy.squarenessDeterminesFitOrFill(aspectFillMinSquareness: aspectFillMinSquareness).square(slightDifferenceImage)

        // Then the result should aspect-fit and become 104x104
        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 104, "Width should match the larger side")
        #expect(result.size.height == 104, "Height should match the larger side")
    }

    // MARK: - Aspect Fit Image Squaring

    @Test
    func wideImageUsingAspectFitShouldBeSquared() {
        let wideImage = createImage(width: 200, height: 100)

        let result = SquaringStrategy.aspectFit.square(wideImage)

        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 200, "Width should match the longer side")
        #expect(result.size.height == 200, "Height should match the longer side")
    }

    @Test
    func tallImageUsingAspectFitShouldBeSquared() {
        let tallImage = createImage(width: 100, height: 200)

        let result = SquaringStrategy.aspectFit.square(tallImage)

        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 200, "Width should match the longer side")
        #expect(result.size.height == 200, "Height should match the longer side")
    }

    @Test
    func squareImageUsingAspectFitShouldBeSquared() {
        let squareImage = createImage(width: 100, height: 100)

        let result = SquaringStrategy.aspectFit.square(squareImage)

        #expect(result == squareImage, "UIImage objects should be identical")
    }

    // MARK: - Aspect Fill Image Squaring

    @Test
    func wideImageUsingAspectFillShouldBeSquared() {
        let wideImage = createImage(width: 200, height: 100)

        let result = SquaringStrategy.aspectFill.square(wideImage)

        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 100, "Width should match the shorter side")
        #expect(result.size.height == 100, "Height should match the shorter side")
    }

    @Test
    func tallImageUsingAspectFillShouldBeSquared() {
        let tallImage = createImage(width: 100, height: 200)

        let result = SquaringStrategy.aspectFill.square(tallImage)

        #expect(result.isSquare(), "Image should be square")
        #expect(result.size.width == 100, "Width should match the shorter side")
        #expect(result.size.height == 100, "Height should match the shorter side")
    }

    @Test
    func squareImageUsingAspectFillShouldBeSquared() {
        let squareImage = createImage(width: 100, height: 100)

        let result = SquaringStrategy.aspectFill.square(squareImage)

        #expect(result == squareImage, "UIImage objects should be identical")
    }

    // MARK: - No Image Squaring

    @Test
    func noCroppingWithMinorAspectDifferenceImageShouldReturnOriginalImage() {
        // Given an image with a minor size difference (97x100) with a squareness of `0.97`, which is below
        // the default `aspectFillMinSquareness` threshold (`0.98`)
        let slightDifferenceImage = createImage(width: 97, height: 100)

        // When the default squaring function is applied
        let result = SquaringStrategy.none.square(slightDifferenceImage)

        // Then it should remain unchanged
        #expect(result == slightDifferenceImage, "UIImage objects should be identical")
    }

    // MARK: - Helpers

    private func createImage(width: CGFloat, height: CGFloat, scale: CGFloat = 1, fillColor: UIColor = .red) -> UIImage {
        let size = CGSize(width: width, height: height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            fillColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
