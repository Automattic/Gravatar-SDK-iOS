import Gravatar
import UIKit

package final class TestImageProcessor: ImageProcessor {
    let image: UIImage?
    package init(image: UIImage? = nil) {
        self.image = image
    }

    package func process(_: Data) -> UIImage? {
        image
    }
}

package final class FailingImageProcessor: ImageProcessor {
    package func process(_: Data) -> UIImage? {
        nil
    }

    package init() {}
}
