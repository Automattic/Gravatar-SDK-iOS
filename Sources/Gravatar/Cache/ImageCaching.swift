import Foundation
import UIKit

public protocol ImageCaching {
    func setImage(_ image: UIImage, forKey key: String)
    func getImage(forKey key: String) -> UIImage?
}

public class ImageCache: ImageCaching {
    private let cache = NSCache<NSString, UIImage>()

    /// The default cache used by the image dowloader.
    public static var shared: ImageCaching = ImageCache()

    public init() {}

    public func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    public func getImage(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}
