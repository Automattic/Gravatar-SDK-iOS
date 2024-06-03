import Foundation
import UIKit

/// Enum defining methods for processing and transforming the image data into a UIImage instance.
///
/// Each case represents a specific processing or transformation method that will be applied to the image data.
public enum ImageProcessingMethod: Sendable {
    /// Apply a custom processor to the image data.
    /// - Parameter processor: An instance of a type conforming to `ImageProcessor`.
    case custom(processor: ImageProcessor)

    /// A processing method which will directly transform the `Data` to an `UIImage` and return it.
    ///
    /// - Parameter scaleFactor: The scale factor to use to create the `UIImage`. If nil,  UITraitCollection's displayScale is used.
    case common(scaleFactor: CGFloat = UITraitCollection.current.displayScale)
}

extension ImageProcessingMethod {
    var processor: ImageProcessor {
        switch self {
        case .common(let scaleFactor):
            DefaultImageProcessor(scaleFactor: scaleFactor)
        case .custom(let processor):
            processor
        }
    }
}
