import Gravatar
import UIKit

package class TestImageCache: ImageCaching, @unchecked Sendable {
    let imageCache = ImageCache()

    package private(set) var getImageCallsCount = 0
    package private(set) var setImageCallsCount = 0
    package private(set) var setTaskCallsCount = 0

    package init() {}

    package func setEntry(_ entry: Gravatar.CacheEntry?, for key: String) {
        guard let entry else {
            imageCache.setEntry(nil, for: key)
            return
        }
        switch entry {
        case .inProgress:
            setTaskCallsCount += 1
        case .ready:
            setImageCallsCount += 1
        }
        imageCache.setEntry(entry, for: key)
    }

    package func getEntry(with key: String) -> Gravatar.CacheEntry? {
        getImageCallsCount += 1
        return imageCache.getEntry(with: key)
    }
}
