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

    package private(set) var getImageCallsCount = 0
    package private(set) var setImageCallsCount = 0
    package private(set) var setTaskCallsCount = 0

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
                setTaskCallsCount += 1
                message = (operation: .inProgress, key: key)
            case .ready:
                setImageCallsCount += 1
                message = (operation: .ready, key: key)
            }
            imageCache.setEntry(entry, for: key)
        }
    }

    package func getEntry(with key: String) -> Gravatar.CacheEntry? {
        accessQueue.sync {
            getImageCallsCount += 1
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
