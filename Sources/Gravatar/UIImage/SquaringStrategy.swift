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
public enum SquaringStrategy {
    /// Sqares the image using an `aspectFill` strategy
    case aspectFill

    /// Sqares the image using an `aspectFit` strategy
    case aspectFit

    /// The defaul squaring strategy
    ///
    /// This strategy uses a high aspectFillMinSquareness to determine `aspectFit` or `aspectFill`.  Only images that are very close to square will use
    /// `aspectFill`, which minimizes the amount of image loss that happens during cropping.  All other images will use `aspectFit`.
    case `default`

    /// No squaring will be applied to images
    case none

    /// Determines the squaring strategy based on how close the image is to square, by comparing the `shortEdge` and `longEdge` of the image.
    ///
    /// `Squareness` is similar to `Aspect Ratio`, except that all values are in the range `0...1`
    /// - A square `UIImage` (`100 x 100`) has a `squareness` of `1`
    /// - A rectangular `UIImage` with a `size` of `100 x 200` (or `200 x 100`) has a squareness of `0.5`
    case squarenessDeterminesFitOrFill(aspectFillMinSquareness: CGFloat)

    package func square(_ image: UIImage) -> UIImage {
        switch self {
        case .aspectFit:
            ImageSquarer(aspectFillMinSquareness: .aspectFitThreshold).square(image)
        case .aspectFill:
            ImageSquarer(aspectFillMinSquareness: .aspectFillThreshold).square(image)
        case .squarenessDeterminesFitOrFill(let aspectFillMinSquareness):
            ImageSquarer(aspectFillMinSquareness: aspectFillMinSquareness).square(image)
        case .default:
            ImageSquarer(aspectFillMinSquareness: .defaultThreshold).square(image)
        case .none:
            // TODO: Check for squareness and log non-square images
            image
        }
    }
}

extension CGFloat {
    fileprivate static let defaultThreshold: CGFloat = 0.98
    fileprivate static let aspectFitThreshold: CGFloat = 1.0
    fileprivate static let aspectFillThreshold: CGFloat = 0.0
}
