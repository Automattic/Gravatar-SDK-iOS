import UIKit

/// The default processor. It applies the scale factor on the given image data and converts it into an image.
public struct DefaultImageProcessor: GravatarImageProcessor {

    public func process(_ data: Data, options: GravatarImageDownloadOptions) -> UIImage? {
        return UIImage(data: data, scale: options.scaleFactor)
    }
}
