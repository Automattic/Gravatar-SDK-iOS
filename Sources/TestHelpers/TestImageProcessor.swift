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

package final class FailingImageProcessor: ImageProcessor {
    package func process(_: Data) -> UIImage? {
        nil
    }

    package init() {}
}
