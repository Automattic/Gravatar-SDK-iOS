import Foundation
import UIKit

/// Processor to apply to the downloaded image data.
public protocol ImageProcessor: Sendable {
    func process(_ data: Data) -> UIImage?
}
