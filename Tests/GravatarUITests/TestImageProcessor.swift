import Foundation
import Gravatar
import UIKit

class TestImageProcessor: ImageProcessor {
    init() {}

    var processedData = false
    func process(_: Data) -> UIImage? {
        processedData = true
        return UIImage()
    }
}
