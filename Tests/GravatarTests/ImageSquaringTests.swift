import UIKit
import XCTest

@testable import Gravatar

final class ImageSquaringTests: XCTestCase {
    // MARK: Pixel Tests

    func testSquareImage() {
        // Given a square image
        let squareImage = createImage(width: 100, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(squareImage)

        // Then it should remain unchanged
        XCTAssertEqual(result, squareImage, "UIImage objects should be identical")
    }

    func testPortraitImage() {
        // Given a portrait image (50x100)
        let portraitImage = createImage(width: 50, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(portraitImage)

        // Then the result should be a square image (100x100)
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 100, "Width should match the taller side")
        XCTAssertEqual(result.size.height, 100, "Height should match the taller side")
    }

    func testLandscapeImage() {
        // Given a landscape image (200x100)
        let landscapeImage = createImage(width: 200, height: 100)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(landscapeImage)

        // Then the result should be a square image (200x200)
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 200, "Width should match the wider side")
        XCTAssertEqual(result.size.height, 200, "Height should match the wider side")
    }

    func testMinorAspectDifferenceBelowCropToFitToleranceImageShouldUseAspectFill() {
        // Given an image with a minor size difference (100x102) where the difference is exactly
        // the default `cropToFitTolerance` of `0.02` (image difference: `0.01`)
        let slightDifferenceImage = createImage(width: 100, height: 101)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(slightDifferenceImage)

        // Then the result should aspect-fill and become 100x100
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 100, "Width should match the smaller side")
        XCTAssertEqual(result.size.height, 100, "Height should match the smaller side")
    }

    func testMinorAspectDifferenceMatchesCropToFitToleranceImageShouldUseAspectFill() {
        // Given an image with a minor size difference (100x102) where the difference is exactly
        // the default `cropToFitTolerance` of `0.02` (image difference: `0.02`)
        let slightDifferenceImage = createImage(width: 100, height: 102)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(slightDifferenceImage)

        // Then the result should aspect-fill and become 100x100
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 100, "Width should match the smaller side")
        XCTAssertEqual(result.size.height, 100, "Height should match the smaller side")
    }

    func testMinorAspectDifferenceAboveCropToFitToleranceImageShouldUseAspectFit() {
        // Given an image with a minor size difference (100x103) where the difference is above
        // the default `cropToFitTolerance` of `0.02` (image difference: `0.03`)
        let slightDifferenceImage = createImage(width: 100, height: 103)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(slightDifferenceImage)

        // Then the result should aspect-fit and become 102x102
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 103, "Width should match the larger side")
        XCTAssertEqual(result.size.height, 103, "Height should match the larger side")
    }

    // MARK: - Extreme Dimensions Tests

    func testVerySmallImage() {
        // Given a very small image (1x1)
        let smallImage = createImage(width: 1, height: 1)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(smallImage)

        // Then it should remain a 1x1 image since it's already square
        XCTAssertTrue(result.isSquare(), "Image should remain square")
        XCTAssertEqual(result.size.width, 1, "Width should remain unchanged")
        XCTAssertEqual(result.size.height, 1, "Height should remain unchanged")
    }

    func testVeryLargeImage() {
        // Given a large image (5_000x3_000)
        let largeImage = createImage(width: 5000, height: 3000)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(largeImage)

        // Then the result should be a 5_000x5_000 square image
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 5000, "Width should match the larger side")
        XCTAssertEqual(result.size.height, 5000, "Height should match the larger side")
    }

    func testWideImage() {
        // Given an extremely wide image (10_000x500)
        let wideImage = createImage(width: 10000, height: 500)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(wideImage)

        // Then the result should be a 10_000x10_000 square image
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 10000, "Width should match the wider side")
        XCTAssertEqual(result.size.height, 10000, "Height should match the wider side")
    }

    func testTallImage() {
        // Given an extremely tall image (500x10_000)
        let tallImage = createImage(width: 500, height: 10000)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(tallImage)

        // Then the result should be a 10_000x10_000 square image
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 10000, "Width should match the taller side")
        XCTAssertEqual(result.size.height, 10000, "Height should match the taller side")
    }

    // MARK: - Scale Test

    func testImageSquaringWithScale2x() {
        // Given a retina image (@2x) with size 300x500
        let image = createImage(width: 300, height: 500, scale: 2.0)

        // When the default squaring strategy is applied
        let result = SquaringStrategy.default.square(image)

        // Then the result should be a 500x500 square image with scale @2x
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 500)
        XCTAssertEqual(result.size.height, 500)
        XCTAssertEqual(result.scale, 2.0, "Image scale should remain @2x")
    }

    // MARK: - Background Color Tests

    @MainActor
    func testDefaultBackgroundColorIsApplied() throws {
        // Given a non-square image (300x500)
        let image = createImage(width: 300, height: 500, scale: 1, fillColor: .red)

        // And a reference image
        let referenceImage = try XCTUnwrap(UIImage(named: "ImageSquaringDefaultBackgroundReferenceImage", in: .module, with: nil)).pngData()

        // When the default squaring strategy is applied
        let resultImage = SquaringStrategy.default.square(image)

        // Archive the reference image for future use
        attach(image: resultImage, attachmentName: "Default Background Image")

        // Then the result should be square
        XCTAssertTrue(resultImage.isSquare(), "The image should be square.")

        // And the generated image should match the reference image
        XCTAssertEqual(resultImage.pngData(), referenceImage)
    }

    // MARK: - Custom Cropping Tolerance

    func testMinorAspectDifferenceBelowCustomCropToFitThresholdImageShouldUseAspectFill() {
        // Given an image with a minor size difference (100x102) where the difference exactly matches
        // a custom `cropToFitTolerance` of `0.02` (image difference: `0.02`)
        let slightDifferenceImage = createImage(width: 100, height: 102)

        // When the custom squaring function is applied
        let result = SquaringStrategy.crop(behavior: .threshold(0.03)).square(slightDifferenceImage)

        // Then the result should aspect-fill and become 100x100
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 100, "Width should match the smaller side")
        XCTAssertEqual(result.size.height, 100, "Height should match the smaller side")
    }

    func testMinorAspectDifferenceMatchesCustomCropToFitThresholdImageShouldUseAspectFill() {
        // Given an image with a minor size difference (100x103) where the difference exactly matches
        // a custom `cropToFitTolerance` of `0.03` (image difference: `0.03`)
        let slightDifferenceImage = createImage(width: 100, height: 103)

        // When the custom squaring function is applied
        let result = SquaringStrategy.crop(behavior: .threshold(0.03)).square(slightDifferenceImage)

        // Then the result should aspect-fill and become 100x100
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 100, "Width should match the smaller side")
        XCTAssertEqual(result.size.height, 100, "Height should match the smaller side")
    }

    func testMinorAspectDifferenceAboveCustomCropToFitThresholdImageShouldUseAspectFill() {
        // Given an image with a minor size difference (100x104) where the difference is above
        // a custom `cropToFitTolerance` of `0.03` (image difference: `0.04`)
        let slightDifferenceImage = createImage(width: 100, height: 104)

        // When the custom squaring function is applied
        let result = SquaringStrategy.crop(behavior: .threshold(0.03)).square(slightDifferenceImage)

        // Then the result should aspect-fit and become 102x102
        XCTAssertTrue(result.isSquare(), "Image should be square")
        XCTAssertEqual(result.size.width, 104, "Width should match the larger side")
        XCTAssertEqual(result.size.height, 104, "Height should match the larger side")
    }

    func testNoCroppingWithMinorAspectDifferenceImageShouldReturnOriginalImage() {
        // Given an image with a minor size difference (100x103) where the difference exactly matches
        // a custom `cropToFitTolerance` set to `nil` (image difference: `0.03`)
        let slightDifferenceImage = createImage(width: 100, height: 103)

        // When the default squaring function is applied
        let result = SquaringStrategy.none.square(slightDifferenceImage)

        // Then it should remain unchanged
        XCTAssertEqual(result, slightDifferenceImage, "UIImage objects should be identical")
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

    @MainActor
    private func attach(image: UIImage, attachmentName: String, lifetime: XCTAttachment.Lifetime = .deleteOnSuccess) {
        XCTContext.runActivity(named: "Archive Image") { activity in
            let attachment = XCTAttachment(image: image)
            attachment.name = attachmentName
            attachment.lifetime = lifetime
            activity.add(attachment)
        }
    }
}
