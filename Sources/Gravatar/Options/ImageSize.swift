import Foundation

/// The size of the image to be requested.
///
/// Gravatar images are always square. Providing the desired square side length is sufficient.
/// Note that many users have lower resolution images. Requesting larger sizes may result in low-quality images.
/// For more info, see [Gravatar Image docs](https://docs.gravatar.com/general/images/#size)
public enum ImageSize {
    /// Points are preferred when working with UI components, such as UIImageView.
    /// - As an example: If the size of the Image View is 40x40, you can request the image size with`.points(40)`.
    /// The suitable pixel value is calculated internally, according to the screen of the user's device.
    case points(CGFloat)
    /// The returned image's size in pixels will be of the exact value passed here.
    case pixels(Int)
}

extension ImageSize {
    func pixels(scaleFactor: CGFloat) -> Int {
        switch self {
        case .pixels(let pixels):
            pixels
        case .points(let points):
            Int(points * scaleFactor)
        }
    }
}
