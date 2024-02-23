import Foundation

/// Enum defining methods for processing and transforming the image data into a UIImage instance.
///
/// Each case represents a specific processing or transformation method that will be applied to the image data.
public enum ImageProcessingMethod {
    /// Apply a custom processor to the image data.
    /// - Parameter processor: An instance of a type conforming to `ImageProcessor`.
    case custom(processor: ImageProcessor)

    /// A processing method which will directly transform the `Data` to an `UIImage` and return it.
    ///
    /// This method will use the appropiate scale factor for the device screen.
    case common
}

extension ImageProcessingMethod {
    var processor: ImageProcessor {
        switch self {
        case .common:
            DefaultImageProcessor.common
        case .custom(let processor):
            processor
        }
    }
}
