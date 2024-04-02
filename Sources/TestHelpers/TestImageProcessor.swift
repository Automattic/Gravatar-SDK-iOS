import Foundation
import UIKit
import Gravatar

public class TestImageProcessor: ImageProcessor {
    
    public init() { }
    
    public var processedData = false
    public func process(_: Data) -> UIImage? {
        processedData = true
        return UIImage()
    }
}
