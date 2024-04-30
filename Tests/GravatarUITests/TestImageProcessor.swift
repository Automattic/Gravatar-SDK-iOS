import Foundation
import Gravatar
import UIKit

final class TestImageProcessor: ImageProcessor {
    init() {}

    var processedData = false
    func process(_: Data) -> UIImage? {
        processedData = true
        return UIImage()
    }
}
