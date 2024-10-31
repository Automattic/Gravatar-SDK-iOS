import UIKit
import XCTest

@testable import Gravatar

final class ImageSquaringTests: XCTestCase {
    // MARK: Pixel Tests

    func testSquareImage() {
        // Given a square image
        let squareImage = createImage(width: 100, height: 100)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(squareImage)

        // Then it should remain unchanged
        XCTAssertEqual(result, squareImage, "UIImage objects should be identical")
    }

    func testPortraitImage() {
        // Given a portrait image (50x100)
        let portraitImage = createImage(width: 50, height: 100)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(portraitImage)

        // Then the result should be a square image (100x100)
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 100, "Width should match the taller side")
        XCTAssertEqual(result.size.height, 100, "Height should match the taller side")
    }

    func testLandscapeImage() {
        // Given a landscape image (200x100)
        let landscapeImage = createImage(width: 200, height: 100)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(landscapeImage)

        // Then the result should be a square image (200x200)
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 200, "Width should match the wider side")
        XCTAssertEqual(result.size.height, 200, "Height should match the wider side")
    }

    func testMinorAspectDifferenceImageShouldUseAspectFill() {
        // Given an image with a minor size difference (100x101) where the difference is below the .minorDifferenceThreshold
        let slightDifferenceImage = createImage(width: 100, height: 101)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(slightDifferenceImage)

        // Then the result should aspect-fill and become 100x100
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 100, "Width should match the smaller side")
        XCTAssertEqual(result.size.height, 100, "Height should match the smaller side")
    }

    func testMinorAspectDifferenceImageShouldUseAspectFit() {
        // Given an image with a minor size difference (100x102) where the difference is at or above the .minorDifferenceThreshold
        let slightDifferenceImage = createImage(width: 100, height: 102)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(slightDifferenceImage)

        // Then the result should aspect-fit and become 102x102
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 102, "Width should match the larger side")
        XCTAssertEqual(result.size.height, 102, "Height should match the larger side")
    }

    // MARK: - Extreme Dimensions Tests

    func testVerySmallImage() {
        // Given a very small image (1x1)
        let smallImage = createImage(width: 1, height: 1)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(smallImage)

        // Then it should remain a 1x1 image since it's already square
        XCTAssertTrue(result.isSquare(), "Image should remain square")
        XCTAssertEqual(result.size.width, 1, "Width should remain unchanged")
        XCTAssertEqual(result.size.height, 1, "Height should remain unchanged")
    }

    func testVeryLargeImage() {
        // Given a large image (5_000x3_000)
        let largeImage = createImage(width: 5000, height: 3000)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(largeImage)

        // Then the result should be a 5_000x5_000 square image
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 5000, "Width should match the larger side")
        XCTAssertEqual(result.size.height, 5000, "Height should match the larger side")
    }

    func testWideImage() {
        // Given an extremely wide image (10_000x500)
        let wideImage = createImage(width: 10000, height: 500)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(wideImage)

        // Then the result should be a 10_000x10_000 square image
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 10000, "Width should match the wider side")
        XCTAssertEqual(result.size.height, 10000, "Height should match the wider side")
    }

    func testTallImage() {
        // Given an extremely tall image (500x10_000)
        let tallImage = createImage(width: 500, height: 10000)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(tallImage)

        // Then the result should be a 10_000x10_000 square image
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 10000, "Width should match the taller side")
        XCTAssertEqual(result.size.height, 10000, "Height should match the taller side")
    }

    // MARK: - Scale Test

    func testImageSquaringWithScale2x() {
        // Given a retina image (@2x) with size 300x500
        let image = createImage(width: 300, height: 500, scale: 2.0)

        // When DefaultImageSquarer is used
        let result = DefaultImageSquarer().squared(image)

        // Then the result should be a 500x500 square image with scale @2x
        XCTAssertTrue(result.isSquare(), "Image should be squared")
        XCTAssertEqual(result.size.width, 500)
        XCTAssertEqual(result.size.height, 500)
        XCTAssertEqual(result.scale, 2.0, "Image scale should remain @2x")
    }

    // MARK: - Background Color Tests

    @MainActor
    func testDefaultBackgroundColorIsApplied() throws {
        // Given a non-square image (300x500)
        let inputImage = createImage(width: 300, height: 500, scale: 1, fillColor: .red)

        // And a reference image
        let referenceImage = try XCTUnwrap(UIImage(named: "ImageSquaringDefaultBackgroundReferenceImage", in: .module, with: nil)).pngData()

        // And a strategy with the default (black) background color
        let cropper = ImageSquaringStrategy.default.cropper

        // When squared() is called
        let resultImage = cropper.squared(inputImage)

        // Archive the reference image for future use
        attach(image: resultImage, attachmentName: "Default Background Image")

        // Then the result should be square
        XCTAssertTrue(resultImage.isSquare(), "The image should be square.")

        // And the generated image should match the reference image
        XCTAssertEqual(resultImage.pngData(), referenceImage)
    }

    @MainActor
    func testCustomBackgroundColorIsApplied() throws {
        // Given a non-square image (300x500)
        let inputImage = createImage(width: 300, height: 500, scale: 1, fillColor: .red)

        // And a reference image
        let referenceImage = try XCTUnwrap(UIImage(named: "ImageSquaringCustomBackgroundReferenceImage", in: .module, with: nil)).pngData()

        // And a strategy with a custom blue background color
        let backgroundColor = UIColor.blue
        let cropper = ImageSquaringStrategy.customBackgroundColor(backgroundColor).cropper

        // When squared() is called
        let resultImage = cropper.squared(inputImage)

        // Archive the reference image for future use
        attach(image: resultImage, attachmentName: "Custom Background Image")

        // Then the result should be square
        XCTAssertTrue(resultImage.isSquare(), "The image should be square.")

        // And the generated image should match the reference image
        XCTAssertEqual(resultImage.pngData(), referenceImage)
    }

    // MARK: - Custom Strategy Tests

    func testCustomImageSquarer() {
        struct CustomCropper: ImageSquaring {
            /// Custom ImageSquarer that halves the height and width
            func squared(_ image: UIImage) -> UIImage {
                let newSize = CGSize(width: image.size.width / 2, height: image.size.height / 2)
                UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return resizedImage!
            }
        }

        // Create a square image
        let image = createImage(width: 200, height: 200)

        // Use a custom cropper
        let squarer = ImageSquaringStrategy.custom(CustomCropper()).cropper

        // Test the custom squaring strategy
        let squaredImage = squarer.squared(image)

        // Assert that the image dimentions have been halved
        XCTAssertEqual(squaredImage.size.width, image.size.width / 2, "The image width should be halved.")
        XCTAssertEqual(squaredImage.size.height, image.size.height / 2, "The image height should be halved.")
    }

    func testCustomImageSquarerAssertsNotSquare() {
        struct CustomCropper: ImageSquaring {
            /// Custom ImageSquarer that halves the height and width
            func squared(_ image: UIImage) -> UIImage {
                let newSize = CGSize(width: image.size.width / 2, height: image.size.height / 2)
                UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                return resizedImage!
            }
        }

        // Create a rectangular image
        let image = createImage(width: 100, height: 200)

        // Use a custom cropper
        let squarer = ImageSquaringStrategy.custom(CustomCropper()).cropper

        // Test the custom squaring strategy
        let squaredImage = squarer.squared(image)

        // Assert that the image dimentions have been halved
        XCTAssertEqual(squaredImage.size.width, image.size.width / 2, "The image width should be halved.")
        XCTAssertEqual(squaredImage.size.height, image.size.height / 2, "The image height should be halved.")
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
