import UIKit

/// The default processor. It applies the scale factor on the given image data and converts it into an image.
struct DefaultImageProcessor: ImageProcessor {
    public static let common = DefaultImageProcessor(scaleFactor: UIScreen.main.scale)

    public let scaleFactor: CGFloat

    public func process(_ data: Data) -> UIImage? {
        UIImage(data: data, scale: scaleFactor)
    }
}
