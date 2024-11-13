import UIKit

/// A strategy for handline images that are not square.
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
    /// Determines the squaring strategy based on how close the image is to square, by comparing the `shortEdge` and `longEdge` of the image.
    ///
    /// `Squareness` is similar to `Aspect Ratio`, except that all values are in the range `0...1`
    /// - A square `UIImage` (`100 x 100`) has a `squareness` of `1`
    /// - A rectangular `UIImage` with a `size` of `100 x 200` (or `200 x 100`) has a squareness of `0.5`
    case squarenessDeterminesFitOrFill(squarenessThreshold: CGFloat)
    case `default`
    case none

    package func square(_ image: UIImage) -> UIImage {
        switch self {
        case .aspectFit:
            ImageSquarer(squarenessThreshold: .aspectFitThreshold).square(image)
        case .aspectFill:
            ImageSquarer(squarenessThreshold: .aspectFillThreshold).square(image)
        case .squarenessDeterminesFitOrFill(let squarenessThreshold):
            ImageSquarer(squarenessThreshold: squarenessThreshold).square(image)
        case .default:
            ImageSquarer(squarenessThreshold: .defaultThreshold).square(image)
        case .none:
            image
        }
    }
}

extension CGFloat {
    fileprivate static let defaultThreshold: CGFloat = 0.98
    fileprivate static let aspectFitThreshold: CGFloat = 1.0
    fileprivate static let aspectFillThreshold: CGFloat = 0.0
}
