import Gravatar
import UIKit

package final class TestImageProcessor: ImageProcessor {
    let identifier: String
    package init(identifier: String = "") {
        self.identifier = identifier
    }

    package func process(_: Data) -> UIImage? {
        let image = UIImage()
        image.accessibilityIdentifier = identifier
        return image
    }
}

final class FailingImageProcessor: ImageProcessor {
    func process(_: Data) -> UIImage? {
        nil
    }
}
