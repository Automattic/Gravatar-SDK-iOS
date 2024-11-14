import UIKit

/// A strategy for handline images that are not square.
///
/// ## Gravatar API
/// The Gravatar API will return an error when an image that is not square is uploaded, even if the difference is a single row of pixels.  `SquaringStrategy` is
/// a safeguard, making sure that an image is properly squared before uploading.
///
/// ## Squareness
/// `Squareness` is similar to `Aspect Ratio`, except that all values are in the range `0...1`
/// - A square UIImage (`100 x 100`) has a `squareness` of `1`
/// - A UIImage with a `size` of `100 x 200` has a `squareness of `0.5`
public enum SquaringStrategy: Sendable {
    /// Crops images that are very close to square using an `.aspectFill` strategy.  All other images are cropped using an `.aspectFit` strategy.
    ///
    /// This strategy trims a small percentage of pixel rows to fix images that appear square to the naked eye,
    /// using a high value for `aspectFillMinSquareness`.
    public static let `default`: SquaringStrategy = .squarenessDeterminesFitOrFill(aspectFillMinSquareness: .defaultMinSquareness)

    /// Square all images by cropping the image to `aspectFill`.
    public static let aspectFill: SquaringStrategy = .squarenessDeterminesFitOrFill(aspectFillMinSquareness: .aspectFillMinSquareness)

    /// Square all iamges by cropping the image to `aspectFit`, and adding a background color to fill in the square
    public static let aspectFit: SquaringStrategy = .squarenessDeterminesFitOrFill(aspectFillMinSquareness: .aspectFitMinSquareness)

    /// Determines the squaring strategy based on how close the image is to square, by defining a minimum squareness for which `aspectFill` will be used,
    /// and below which `.aspectFit` will be used.
    ///
    /// This `SquaringStrategy` is intended to crop non-square images responsbility.  When an image is only slighlyt off from square, we can safely trim the
    /// image in order to square it.  For images that are more rectangular, cropping to `aspectFit` may meaningful impact the image.  In those cases, we crop to
    /// `aspectFit`, and then add a background color to fill in the square.
    case squarenessDeterminesFitOrFill(aspectFillMinSquareness: CGFloat)

    /// No squaring will be applied to images
    case none

    /// Applies the `SquaringStrategy` to a `UIImage`
    /// - Parameter image: a `UIImage` that should be squared
    /// - Returns: a `UIImage` with the `SquaringStrategy` applied.
    package func square(_ image: UIImage) -> UIImage {
        switch self {
        case .squarenessDeterminesFitOrFill(let aspectFillMinSquareness):
            ImageSquarer(aspectFillMinSquareness: aspectFillMinSquareness).square(image)
        case .none:
            // TODO: Check for squareness and log non-square images
            image
        }
    }
}

extension CGFloat {
    /// The default `aspecptFillMinSquareness` value
    fileprivate static let defaultMinSquareness: CGFloat = 0.98

    /// The `aspectFillMinSquareness` value that will cause the `SquaringStrategy` to apply `aspectFit` squaring logic to all images
    fileprivate static let aspectFitMinSquareness: CGFloat = 1.0

    /// The `aspectFillMinSquareness` value that will cause the `SquaringStrategy` to apply `aspectFill` squaring logic to all images
    fileprivate static let aspectFillMinSquareness: CGFloat = 0.0
}
