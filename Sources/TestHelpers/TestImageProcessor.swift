import Gravatar
import UIKit

final class TestImageProcessor: ImageProcessor {
    let identifier: String
    init(identifier: String = "") {
        self.identifier = identifier
    }

    func process(_: Data) -> UIImage? {
        let image = UIImage()
        image.accessibilityIdentifier = identifier
        return image
    }
}
