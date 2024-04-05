import Foundation
import Gravatar
import UIKit

class TestImageCache: ImageCaching {
    var dict: [String: UIImage] = [:]
    var getImageCallCount = 0
    var setImageCallsCount = 0

    init() {}

    func setImage(_ image: UIImage, forKey key: String) {
        setImageCallsCount += 1
        dict[key] = image
    }

    func getImage(forKey key: String) -> UIImage? {
        getImageCallCount += 1
        return dict[key]
    }
}
