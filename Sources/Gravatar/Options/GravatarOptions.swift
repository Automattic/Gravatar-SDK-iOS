import Foundation
import UIKit

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
        garavatarRating rating: ImageRating? = nil,
        preferredSize size: ImageSize? = nil,
        defaultImageOption: DefaultImageOption? = nil
    ) -> ImageDownloadOptions {
        ImageDownloadOptions(
            preferredSize: size,
            rating: rating,
            forceRefresh: forceRefresh,
            defaultImageOption: defaultImageOption,
            processingMethod: processingMethod
        )
    }
}

/// Download options to use outside of `GravatarCompatible` UI components. Refer to `ImageSettingOption`.
public struct ImageDownloadOptions {
    let forceRefresh: Bool
    let processingMethod: ImageProcessingMethod
    let imageQueryOptions: ImageQueryOptions

    private let preferredSize: ImageSize?

    /// Creates a new `GravatarImageDownloadOptions` with the given options.
    ///
    /// When passing `nil` to the optional parameters, the backend defaults are going to be used.
    /// For more info about backend defaults, see https://docs.gravatar.com/general/images/
    /// - Parameters:
    ///   - preferredSize: Preferred image size (set to `nil` for default size)
    ///   - gravatarRating: Maximum rating for image (set to `nil` for default rating)
    ///   - forceRefresh: Force the image to be downloaded, ignoring the cache
    ///   - forceDefaultImage: If `true`, the returned image will always be the default image, determined by the `defaultImageOption` parameter.
    ///   - defaultImageOption: Configure the default image (set to `nil` to use the default default image)
    ///   - processingMethod: Method to use for processing the downloaded `Data`
    public init(
        preferredSize: ImageSize? = nil,
        rating: ImageRating? = nil,
        forceRefresh: Bool = false,
        forceDefaultImage: Bool? = nil,
        defaultImageOption: DefaultImageOption? = nil,
        processingMethod: ImageProcessingMethod = .common
    ) {
        self.forceRefresh = forceRefresh
        self.processingMethod = processingMethod
        self.preferredSize = preferredSize

        self.imageQueryOptions = ImageQueryOptions(
            preferredSize: preferredSize,
            rating: rating,
            defaultImageOption: defaultImageOption,
            forceDefaultImage: forceDefaultImage
        )
    }
}
