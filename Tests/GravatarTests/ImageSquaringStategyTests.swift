import Gravatar
import XCTest

class ImageSquaringTests: XCTestCase {
    // Test squaring strategy using default squaring method
    func testDefaultImageSquarerForSquareImage() {
        // Create a square image
        let image = createTestImage(width: 100, height: 100)

        // Use the default squaring strategy
        let squarer = ImageSquaringStrategy.default.strategy

        // Test if squared method returns the same image
        let squaredImage = squarer.squared(image)

        XCTAssertTrue(squaredImage.isSquare(), "The image should remain square.")
        XCTAssertEqual(squaredImage.size, image.size, "The square image's dimensions should not change.")
    }

    // Test squaring strategy using default squaring method for a non-square image
    func testDefaultImageSquarerForNonSquareImage() {
        // Create a rectangular image
        let image = createTestImage(width: 100, height: 200)

        // Use the default squaring strategy
        let squarer = ImageSquaringStrategy.default.strategy

        // Test the squaring of the image
        let squaredImage = squarer.squared(image)

        XCTAssertTrue(squaredImage.isSquare(), "The resulting image should be square.")
        XCTAssertEqual(squaredImage.size.width, squaredImage.size.height, "The width and height of the squared image should be equal.")
    }

    // Test the behavior of the custom squaring strategy
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

        // Create a rectangular image
        let image = createTestImage(width: 100, height: 200)

        // Use a custom cropper
        let squarer = ImageSquaringStrategy.custom(cropper: CustomCropper()).strategy

        // Test the custom squaring strategy
        let squaredImage = squarer.squared(image)

        // Assert that the image size has been halved
        XCTAssertEqual(squaredImage.size.width, image.size.width / 2, "The image width should be halved.")
        XCTAssertEqual(squaredImage.size.height, image.size.height / 2, "The image height should be halved.")
    }

    // Test if the squared method handles very small size differences correctly
    func testSquaringForSmallSizeDifference() {
        // Create an image with a small size difference
        let image = createTestImage(width: 100, height: 101)

        // Use the default squaring strategy
        let squarer = ImageSquaringStrategy.default.strategy

        // Test if squared image uses aspect fill (min of width and height)
        let squaredImage = squarer.squared(image)

        XCTAssertEqual(squaredImage.size.width, 100, "The squared image should have the smaller size as the side.")
        XCTAssertEqual(squaredImage.size.height, 100, "The squared image should have the smaller size as the side.")
    }
}

extension ImageSquaringTests {
    // Helper function to create images with given width and height
    func createTestImage(width: CGFloat, height: CGFloat, color: UIColor = .red) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
