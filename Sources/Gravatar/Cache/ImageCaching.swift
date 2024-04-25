import UIKit

/// Represents a cache for images
///
/// An ImageCaching will cache the task of obtaining an image from remote.
/// Requesting an image from cache should await for any task cached and return the image from this task instead of creating a new task.
public protocol ImageCaching: Sendable {
    /// Saves an image in the cache.
    /// - Parameters:
    ///   - image: The image to set
    ///   - key: The Image's URL.
    func setImage(_ image: UIImage, for key: URL) async

    /// Saves a task used to request the image into the cache.
    ///
    /// This should be used to avoid requesting the same image multiple times while the image is already being requested.
    /// If you don't need this behavior, you can opt out by not implementing this function.
    /// - Parameters:
    ///   - task: The task to set.
    ///   - key: The image's URL.
    func setTask(_ task: Task<UIImage, Error>, for key: URL) async

    /// Gets an image from cache for the given URL, or nil if none is found.
    ///
    /// If a task is found for the given URL, this  will await until the task returns the image.
    /// - Parameter key: The image URL.
    /// - Returns: The image cached for the given URL, or nil if none is found.
    func getImage(for key: URL) async throws -> UIImage?
}

/// Making `setTask` optional.
extension ImageCaching {
    public func setTask(_ task: Task<UIImage, Error>, for key: URL) async {}
}

/// The default `ImageCaching` used by this SDK.
public actor ImageCache: ImageCaching {
    private let cache = NSCache<NSString, CacheEntryObject>()

    /// The default cache used by the image dowloader.
    public static var shared: ImageCaching = ImageCache()

    public init() {}

    public func setImage(_ image: UIImage, for key: URL) {
        cache[key] = .ready(image)
    }

    public func setTask(_ task: Task<UIImage, Error>, for key: URL) async {
        cache[key] = .inProgress(task)
    }

    public func getImage(for key: URL) async throws -> UIImage? {
        switch cache[key] {
        case .ready(let image):
            image
        case .inProgress(let task):
            try await task.value
        case .none:
            nil
        }
    }
}

private enum CacheEntry: Sendable {
    case inProgress(Task<UIImage, Error>)
    case ready(UIImage)
}

private final class CacheEntryObject {
    let entry: CacheEntry
    init(entry: CacheEntry) { self.entry = entry }
}

extension NSCache where KeyType == NSString, ObjectType == CacheEntryObject {
    fileprivate subscript(_ url: URL) -> CacheEntry? {
        get {
            let key = url.absoluteString as NSString
            let value = object(forKey: key)
            return value?.entry
        }
        set {
            let key = url.absoluteString as NSString
            if let entry = newValue {
                let value = CacheEntryObject(entry: entry)
                setObject(value, forKey: key)
            } else {
                removeObject(forKey: key)
            }
        }
    }
}
