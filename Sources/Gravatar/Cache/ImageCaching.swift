import UIKit

/// Represents a cache for images.
///
/// An ImageCaching represents a cache for CacheEntry elements. Each CacheEntry is either an instance of an image, or the task of retrieving an image from
/// remote.
public protocol ImageCaching {
    /// Saves an image in the cache.
    /// - Parameters:
    ///   - image: The cache entry to set.
    ///   - key: The entry's key, used to be found via `.getEntry(key:)`.
    func setEntry(_ entry: CacheEntry, for key: String)

    /// Gets a `CacheEntry` from cache for the given key, or nil if none is found.
    ///
    /// - Parameter key: The key for the entry to get.
    /// - Returns: The cache entry which could contain an image, the task that is retrieving the image. Nil is returned if nothing is found.
    ///
    /// `.inProgress(task)`  is used by the image downloader to check if there's already an ongoing download task for the same image. If yes, the image
    /// downloader  awaits that ask instead of starting a new one.
    func getEntry(with key: String) -> CacheEntry?
}

/// The default `ImageCaching` used by this SDK.
public struct ImageCache: ImageCaching {
    private let cache = NSCache<NSString, CacheEntryObject>()

    /// The default cache used by the image dowloader.
    public static let shared: ImageCaching = ImageCache()

    public init() {}

    public func setEntry(_ entry: CacheEntry, for key: String) {
        cache[key] = .init(entry)
    }

    public func getEntry(with key: String) -> CacheEntry? {
        cache[key]
    }
}

/// ImageCache can save an in-progress task of retreiving an image from remote.
/// This enum represent both possible states for an image in the cache system.
public enum CacheEntry: Sendable {
    /// A task of retreiving an image is in progress.
    case inProgress(Task<UIImage, Error>)
    /// An image instance is readily available.
    case ready(UIImage)
}

private final class CacheEntryObject {
    let entry: CacheEntry
    init(entry: CacheEntry) { self.entry = entry }
}

extension NSCache where KeyType == NSString, ObjectType == CacheEntryObject {
    fileprivate subscript(_ key: String) -> CacheEntry? {
        get {
            let key = key as NSString
            let value = object(forKey: key)
            return value?.entry
        }
        set {
            let key = key as NSString
            if let entry = newValue {
                let value = CacheEntryObject(entry: entry)
                setObject(value, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }
}
