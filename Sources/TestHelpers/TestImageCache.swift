import Gravatar
import UIKit

package class TestImageCache: ImageCaching, @unchecked Sendable {
    let imageCache = ImageCache()

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
    private let accessQueue = DispatchQueue(label: "com.testImageCache.accessQueue")

    package init() {}

    package func setEntry(_ entry: Gravatar.CacheEntry?, for key: String) {
        accessQueue.sync {
            var message: CacheMessage
            defer { cacheMessages.append(message) }
            guard let entry else {
                imageCache.setEntry(nil, for: key)
                message = (operation: .setToNil, key: key)
                return
            }
            switch entry {
            case .inProgress:
                message = (operation: .inProgress, key: key)
            case .ready:
                message = (operation: .ready, key: key)
            }
            imageCache.setEntry(entry, for: key)
        }
    }

    package func getEntry(with key: String) -> Gravatar.CacheEntry? {
        accessQueue.sync {
            cacheMessages.append(CacheMessage(operation: .get, key: key))
            return imageCache.getEntry(with: key)
        }
    }

    package func messageCount(type: CacheMessageType) -> Int {
        accessQueue.sync {
            cacheMessages.filter { $0.operation == type }.count
        }
    }
}
