import UIKit

/// The default processor. It applies the scale factor on the given image data and converts it into an image.
actor DefaultImageProcessor: ImageProcessor {
    public static let common = DefaultImageProcessor(scaleFactor: UI.scaleFactor)

    public let scaleFactor: CGFloat
    
    init(scaleFactor: CGFloat) {
        self.scaleFactor = scaleFactor
    }

    nonisolated public func process(_ data: Data) -> UIImage? {
        UIImage(data: data, scale: scaleFactor)
    }
}
