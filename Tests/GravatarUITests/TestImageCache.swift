import Gravatar
import UIKit

actor TestImageCache: ImageCaching {
    var dict: [String: CacheEntryWrapper] = [:]

    private var _getImageCallCount = 0
    private var _setImageCallsCount = 0
    private var _setTaskCallCount = 0

    func setEntry(_ entry: Gravatar.CacheEntry, for key: String) async {
        switch entry {
        case .inProgress:
            _setTaskCallCount += 1
        case .ready:
            _setImageCallsCount += 1
        }
        dict[key] = CacheEntryWrapper(entry)
    }

    func getEntry(with key: String) async -> Gravatar.CacheEntry? {
        _getImageCallCount += 1
        return dict[key]?.cacheEntry
    }

    var setImageCallsCount: Int {
        get async {
            _setImageCallsCount
        }
    }

    var getImageCallsCount: Int {
        get async {
            _getImageCallCount
        }
    }

    var setTaskCallCount: Int {
        get async {
            _setTaskCallCount
        }
    }
}

struct CacheEntryWrapper: Sendable {
    let cacheEntry: CacheEntry
    init(_ cacheEntry: CacheEntry) {
        self.cacheEntry = cacheEntry
    }
}
