import Foundation
import UIKit

/// Processor to apply to the downloaded image data. 
public protocol GravatarImageProcessor {
    func process(_ data: Data, options: GravatarImageDownloadOptions) -> UIImage?
}
