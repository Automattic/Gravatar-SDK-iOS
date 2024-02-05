import Foundation
import UIKit

/// Options to use when fetching a Gravatar profile image and setting it to a `GravatarCompatible` UI component.
public enum GravatarImageSettingOption {
    // The value is used when converting the retrieved data to an image.
    // Default value is: UIScreen.main.scale. You may set values as `1.0`, `2.0`, `3.0`.
    case scaleFactor(CGFloat)

    // Transition style to use when setting the new image downloaded. Default: .none
    case transition(GravatarImageTransition)

    // By setting this option, the current image will be removed and the placeholder will be shown while downloading the new image. Default: false
    case removeCurrentImageWhileLoading

    // Ignore the cached value and re-download the image. Default: false
    case forceRefresh
    
    // Processor to run on the the downloaded data while converting it into an image.
    // If not set `DefaultImageProcessor.common` will be used.
    case processor(GravatarImageProcessor)
    
    // By setting this you can pass a cache of your preference to save the downloaded image. Default: GravatarImageCache.shared
    case imageCache(GravatarImageCaching)
    
    // A custom image downloader. Defaults to `GravatarimageDownloader` if not set.
    case imageDownloader(GravatarImageRetrieverProtocol)
}

// Parsed options derived from [GravatarImageSettingOption]
public struct GravatarImageSettingOptions {
    var scaleFactor: CGFloat = UIScreen.main.scale
    var transition: GravatarImageTransition = .none
    var removeCurrentImageWhileLoading = false
    var forceRefresh = false
    var processor: GravatarImageProcessor = DefaultImageProcessor.common
    var imageCache: GravatarImageCaching = GravatarImageCache.shared
    var imageDownloader: GravatarImageRetrieverProtocol? = nil

    init(options: [GravatarImageSettingOption]?) {
        guard let options = options else { return }
        for option in options {
            switch option {
            case .scaleFactor(let scale):
                scaleFactor = scale
            case .transition(let imageTransition):
                transition = imageTransition
            case .removeCurrentImageWhileLoading:
                removeCurrentImageWhileLoading = true
            case .forceRefresh:
                forceRefresh = true
            case .processor(let imageProcessor):
                processor = imageProcessor
            case .imageCache(let customCache):
                imageCache = customCache
            case .imageDownloader(let retriever):
                imageDownloader = retriever
            }
        }
    }
    
    func deriveDownloadOptions(garavatarRating rating: GravatarRating, preferredSize size: CGSize) -> GravatarImageDownloadOptions {
        return GravatarImageDownloadOptions(
            scaleFactor: scaleFactor,
            gravatarRating: rating,
            preferredSize: size,
            forceRefresh: forceRefresh,
            processor: processor
        )
    }
}

// Download options to use outside of `GravatarCompatible` UI components. Refer to `GravatarImageSettingOption`.
public struct GravatarImageDownloadOptions {
    static let defaultSize: CGSize = .init(width: 80, height: 80)
    
    let scaleFactor: CGFloat
    let gravatarRating: GravatarRating
    let preferredSize: CGSize?
    let forceRefresh: Bool
    let processor: GravatarImageProcessor

    public init(scaleFactor: CGFloat = UIScreen.main.scale, gravatarRating: GravatarRating = .default, preferredSize: CGSize? = nil, forceRefresh: Bool = false, processor: GravatarImageProcessor = DefaultImageProcessor.common) {
        self.scaleFactor = scaleFactor
        self.gravatarRating = gravatarRating
        self.preferredSize = preferredSize
        self.forceRefresh = forceRefresh
        self.processor = processor
    }
}
