import Foundation
import UIKit
import Gravatar

/// Options to use when fetching a Gravatar profile image and setting it to a `GravatarCompatible` UI component.
public enum ImageSettingOption {
    /// Transition style to use when setting the new image downloaded. Default: .none
    case transition(ImageTransition)

    /// By setting this option, the current image will be removed and the placeholder will be shown while downloading the new image. Default: false
    case removeCurrentImageWhileLoading

    /// Ignore the cached value and re-download the image. Default: `false`
    case forceRefresh

    /// Processing method to be used to transform the `Data` into a `UIImage` instance.
    ///
    /// If not set `ImageProcessingMethod.common` will be used.
    case processingMethod(ImageProcessingMethod)

    /// By setting this you can pass a cache of your preference to save the downloaded image.
    ///
    /// If not set, an internal cache will be used.
    case imageCache(ImageCaching)

    /// A custom image downloader. Defaults to `GravatarimageDownloader` if not set.
    case imageDownloader(ImageDownloader)
}

/// Parsed options derived from [ImageSettingOption]
public struct ImageSettingOptions {
    var transition: ImageTransition = .none
    var removeCurrentImageWhileLoading = false
    var forceRefresh = false
    var processingMethod: ImageProcessingMethod = .common
    var imageCache: ImageCaching = ImageCache.shared
    var imageDownloader: ImageDownloader? = nil

    init(options: [ImageSettingOption]?) {
        guard let options else { return }
        for option in options {
            switch option {
            case .transition(let imageTransition):
                transition = imageTransition
            case .removeCurrentImageWhileLoading:
                removeCurrentImageWhileLoading = true
            case .forceRefresh:
                forceRefresh = true
            case .processingMethod(let method):
                processingMethod = method
            case .imageCache(let customCache):
                imageCache = customCache
            case .imageDownloader(let retriever):
                imageDownloader = retriever
            }
        }
    }

    func deriveDownloadOptions(
        garavatarRating rating: Rating? = nil,
        preferredSize size: ImageSize? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil
    ) -> ImageDownloadOptions {
        ImageDownloadOptions(
            preferredSize: size,
            rating: rating,
            forceRefresh: forceRefresh,
            defaultAvatarOption: defaultAvatarOption,
            processingMethod: processingMethod
        )
    }
}
