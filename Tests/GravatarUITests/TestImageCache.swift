import Gravatar
import UIKit

actor TestImageCache: ImageCaching {
    var dict: [String: CacheEntryWrapper] = [:]

    private(set) var getImageCallsCount = 0
    private(set) var setImageCallsCount = 0
    private(set) var setTaskCallsCount = 0

    func setEntry(_ entry: Gravatar.CacheEntry, for key: String) async {
        switch entry {
        case .inProgress:
            setTaskCallsCount += 1
        case .ready:
            setImageCallsCount += 1
        }
        dict[key] = CacheEntryWrapper(entry)
    }

    func getEntry(with key: String) async -> Gravatar.CacheEntry? {
        getImageCallsCount += 1
        return dict[key]?.cacheEntry
    }
}

struct CacheEntryWrapper: Sendable {
    let cacheEntry: CacheEntry
    init(_ cacheEntry: CacheEntry) {
        self.cacheEntry = cacheEntry
    }
}
