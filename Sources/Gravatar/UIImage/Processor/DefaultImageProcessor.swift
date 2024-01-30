import UIKit

/// The default processor. It applies the scale factor on the given image data and converts it into an image.
public struct DefaultImageProcessor: GravatarImageProcessor {
    
    public static let common = DefaultImageProcessor(scaleFactor: UIScreen.main.scale)

    public let scaleFactor: CGFloat
    
    public func process(_ data: Data) -> UIImage? {
        return UIImage(data: data, scale: scaleFactor)
    }
}

struct ImageProcessor: ImageProcessing {}

protocol ImageProcessing {
    func process(data: Data, with scaleFactor: CGFloat) -> UIImage?
}

extension ImageProcessing {
    func process(data: Data, with scaleFactor: CGFloat = UIScreen.main.scale) -> UIImage? {
        UIImage(data: data, scale: scaleFactor)
    }
}
