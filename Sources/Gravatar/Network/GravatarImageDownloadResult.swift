import Foundation
import UIKit

/// Represents the result of a  Gravatar image download task.
public struct GravatarImageDownloadResult {
    
    public init(image: UIImage, sourceURL: URL) {
        self.image = image
        self.sourceURL = sourceURL
    }
    
    /// Gets the image of this result.
    public let image: UIImage

    /// The `URL` which this result is related to.
    public let sourceURL: URL
}
