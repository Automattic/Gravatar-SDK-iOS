import Foundation
import Gravatar
import UIKit

public class TestImageCache: ImageCaching {
    var dict: [String: UIImage] = [:]
    public var getImageCallCount = 0
    public var setImageCallsCount = 0

    public init() {}

    public func setImage(_ image: UIImage, forKey key: String) {
        setImageCallsCount += 1
        dict[key] = image
    }

    public func getImage(forKey key: String) -> UIImage? {
        getImageCallCount += 1
        return dict[key]
    }
}
