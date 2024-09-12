import Gravatar
import UIKit

package class TestImageCache: ImageCaching, @unchecked Sendable {
    var dict: [String: CacheEntryWrapper] = [:]

    package private(set) var getImageCallsCount = 0
    package private(set) var setImageCallsCount = 0
    package private(set) var setTaskCallsCount = 0

    package init() {}

    package func setEntry(_ entry: Gravatar.CacheEntry?, for key: String) {
        guard let entry else {
            dict[key] = nil
            return
        }
        switch entry {
        case .inProgress:
            setTaskCallsCount += 1
        case .ready:
            setImageCallsCount += 1
        }
        dict[key] = CacheEntryWrapper(entry)
    }

    package func getEntry(with key: String) -> Gravatar.CacheEntry? {
        getImageCallsCount += 1
        return dict[key]?.cacheEntry
    }
}

package struct CacheEntryWrapper: Sendable {
    let cacheEntry: CacheEntry
    package init(_ cacheEntry: CacheEntry) {
        self.cacheEntry = cacheEntry
    }
}
