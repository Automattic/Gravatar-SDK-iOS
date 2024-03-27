import Foundation
import UIKit

/// Processor to apply to the downloaded image data.
public protocol ImageProcessor: Actor {
    func process(_ data: Data) async -> UIImage?
}
