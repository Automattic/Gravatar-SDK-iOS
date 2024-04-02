import Foundation
import Gravatar
import UIKit

public class TestImageProcessor: ImageProcessor {
    public init() {}

    public var processedData = false
    public func process(_: Data) -> UIImage? {
        processedData = true
        return UIImage()
    }
}
