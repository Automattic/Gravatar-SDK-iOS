import Foundation
import UIKit

/// The size of the image to be requested.
///
/// Gravatar images are always square. Providing the desired square side length is sufficient.
/// Note that many users have lower resolution images. Requesting larger sizes may result in low-quality images.
/// For more info, see [Gravatar Image docs](https://docs.gravatar.com/general/images/#size)
public struct ImageSize {
    /// Points are preferred when working with UI components, such as UIImageView.
    /// - As an example: If the size of the Image View is 40x40, you can request the image size with`.points(40)`.
    /// The suitable pixel value is calculated internally, according to the screen of the user's device.
    let points: CGFloat

    /// The returned image's size in pixels
    var pixels: Int {
        Int((points * scaleFactor).rounded())
    }

    /// The scale factor for converting points to pixels.   In most cases, this should be the natural scale factor
    /// associated with the device.
    private let scaleFactor: CGFloat

    /// A struct representing the width of a square image
    /// - Parameters:
    ///   - points: Image width in points
    ///   - scaleFactor: Scale factor for determining pixels. In most cases, this should be the natural scale factor associated with the device.
    init(points: CGFloat, scaleFactor: CGFloat = UIScreen.main.scale) {
        self.points = points
        self.scaleFactor = scaleFactor
    }
}

extension ImageSize {
    /// A struct representing the width of a square image
    /// - Parameters:
    ///   - points: Image width in points
    ///   - scaleFactor: Scale factor for determining pixels. In most cases, this should be the natural scale factor associated with the device.
    init?(points: CGFloat?, scaleFactor: CGFloat = UIScreen.main.scale) {
        guard let points else { return nil }
        self.init(points: points, scaleFactor: scaleFactor)
    }

    /// A struct representing the width of a square image
    /// - Parameters:
    ///   - pixels: Image width in pixels
    ///   - scaleFactor: Scale factor for converting to points. In most cases, this should be the natural scale factor associated with the device.
    init(pixels: Int, scaleFactor: CGFloat = UIScreen.main.scale) {
        let points = CGFloat(pixels) / scaleFactor
        self.init(points: points, scaleFactor: scaleFactor)
    }

    /// A struct representing the width of a square image
    /// - Parameters:
    ///   - size: CGSize of image
    ///   - scaleFactor: Scale factor for converting to points. In most cases, this should be the natural scale factor associated with the device.
    init?(size: CGSize?, scaleFactor: CGFloat = UIScreen.main.scale) {
        guard let size else { return nil }
        self.init(points: size.width, scaleFactor: scaleFactor)
    }
}
