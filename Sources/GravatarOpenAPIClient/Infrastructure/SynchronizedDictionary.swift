import Foundation

struct SynchronizedDictionary<K: Hashable, V> {
    private var dictionary = [K: V]()
    private let lock = NSRecursiveLock()

    subscript(key: K) -> V? {
        get {
            lock.withLock {
                self.dictionary[key]
            }
        }
        set {
            lock.withLock {
                self.dictionary[key] = newValue
            }
        }
    }
}
