import Gravatar
import UIKit

actor TestImageCache: ImageCaching {
    var dict: [String: CacheEntryWrapper] = [:]

    var getImageCallCount = 0
    var setImageCallsCount = 0
    var setTaskCallCount = 0

    func setEntry(_ entry: Gravatar.CacheEntry, for key: String) async {
        switch entry {
        case .inProgress:
            setTaskCallCount += 1
        case .ready:
            setImageCallsCount += 1
        }
        dict[key] = CacheEntryWrapper(entry)
    }

    func getEntry(with key: String) async -> Gravatar.CacheEntry? {
        getImageCallCount += 1
        return dict[key]?.cacheEntry
    }
}

class CacheEntryWrapper {
    let cacheEntry: CacheEntry
    init(_ cacheEntry: CacheEntry) {
        self.cacheEntry = cacheEntry
    }
}
