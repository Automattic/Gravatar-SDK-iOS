import Gravatar
import UIKit

package final class TestImageCache: ImageCaching, @unchecked Sendable {
    private var cache: [String: CacheEntry] = [:]

    package typealias CacheMessage = (operation: CacheMessageType, key: String)
    private var cacheMessages = [CacheMessage]()

    package enum CacheMessageType {
        case setToNil
        case inProgress
        case ready
        case get
    }

    package var getImageCallsCount: Int { messageCount(type: .get) }
    package var setImageCallsCount: Int { messageCount(type: .ready) }
    package var setTaskCallsCount: Int { messageCount(type: .inProgress) }

    // Serial queue to synchronize access to shared mutable state
    private let accessQueue = DispatchQueue(label: "com.testImageCache.accessQueue", attributes: .concurrent)

    package init() {}

    package func setEntry(_ entry: Gravatar.CacheEntry?, for key: String) {
        accessQueue.async(flags: .barrier) {
            guard let entry else {
                self.cache[key] = nil
                self.cacheMessages.append((operation: .setToNil, key: key))
                return
            }

            switch entry {
            case .inProgress:
                self.cacheMessages.append((operation: .inProgress, key: key))
            case .ready:
                self.cacheMessages.append((operation: .ready, key: key))
            }

            self.cache[key] = entry
        }
    }

    package func getEntry(with key: String) -> Gravatar.CacheEntry? {
        accessQueue.sync {
            cacheMessages.append(CacheMessage(operation: .get, key: key))
            return cache[key]
        }
    }

    package func clear() {
        accessQueue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }

    package func messageCount(type: CacheMessageType) -> Int {
        accessQueue.sync {
            cacheMessages.filter { $0.operation == type }.count
        }
    }

    package func messageCount(type: CacheMessageType, forKey key: String) -> Int {
        accessQueue.sync {
            cacheMessages.filter { $0.operation == type && $0.key == key }.count
        }
    }
}
