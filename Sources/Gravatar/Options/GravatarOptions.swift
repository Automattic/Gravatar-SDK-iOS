import Foundation
import UIKit

/// Options to use when fetching a Gravatar profile image and setting it to a `GravatarCompatible` UI component.
public enum GravatarImageSettingOption {
    /// Transition style to use when setting the new image downloaded. Default: .none
    case transition(GravatarImageTransition)

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

/// Parsed options derived from [GravatarImageSettingOption]
public struct GravatarImageSettingOptions {
    var transition: GravatarImageTransition = .none
    var removeCurrentImageWhileLoading = false
    var forceRefresh = false
    var processingMethod: ImageProcessingMethod = .common
    var imageCache: ImageCaching = ImageCache.shared
    var imageDownloader: ImageDownloader? = nil

    init(options: [GravatarImageSettingOption]?) {
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
        defaultImage: DefaultImageOption? = nil
    ) -> GravatarImageDownloadOptions {
        GravatarImageDownloadOptions(
            preferredSize: size,
            rating: rating,
            forceRefresh: forceRefresh,
            defaultImage: defaultImage,
            processingMethod: processingMethod
        )
    }
}

/// Download options to use outside of `GravatarCompatible` UI components. Refer to `GravatarImageSettingOption`.
public struct GravatarImageDownloadOptions {
    let rating: ImageRating?
    let forceRefresh: Bool
    let forceDefaultImage: Bool?
    let defaultImage: DefaultImageOption?
    let processingMethod: ImageProcessingMethod
    let preferredPixelSize: Int?

    private let preferredSize: ImageSize?
    private let scaleFactor: CGFloat

    /// GravatarImageDownloadOptions initializer
    /// - Parameters:
    ///   - preferredSize: preferred image size (set to `nil` for default size)
    ///   - gravatarRating: maximum rating for image (set to `nil` for default rating)
    ///   - forceRefresh: force the image to be downloaded, ignoring the cache
    ///   - forceDefaultImage: force the default image to be used (set to `nil` for default value)
    ///   - defaultImage: configure the default image (set to `nil` to use the default default image)
    ///   - processor: processor for handling the downloaded `Data`
    public init(
        preferredSize: ImageSize? = nil,
        rating: ImageRating? = nil,
        forceRefresh: Bool = false,
        forceDefaultImage: Bool? = nil,
        defaultImage: DefaultImageOption? = nil,
        processingMethod: ImageProcessingMethod = .common
    ) {
        self.init(
            scaleFactor: UIScreen.main.scale,
            preferredSize: preferredSize,
            rating: rating,
            forceRefresh: forceRefresh,
            forceDefaultImage: forceDefaultImage,
            defaultImage: defaultImage,
            processingMethod: processingMethod
        )
    }

    private init(
        scaleFactor: CGFloat,
        preferredSize: ImageSize? = nil,
        rating: ImageRating? = nil,
        forceRefresh: Bool = false,
        forceDefaultImage: Bool? = nil,
        defaultImage: DefaultImageOption? = nil,
        processingMethod: ImageProcessingMethod
    ) {
        self.rating = rating
        self.forceRefresh = forceRefresh
        self.forceDefaultImage = forceDefaultImage
        self.processingMethod = processingMethod
        self.defaultImage = defaultImage
        self.scaleFactor = scaleFactor
        self.preferredSize = preferredSize

        switch preferredSize {
        case .pixels(let pixels):
            preferredPixelSize = pixels
        case .points(let points):
            preferredPixelSize = Int(points * scaleFactor)
        case .none:
            preferredPixelSize = nil
        }
    }

    func updating(
        scaleFactor: CGFloat? = nil,
        preferredSize: ImageSize? = nil,
        rating: ImageRating? = nil,
        forceRefresh: Bool? = nil,
        forceDefaultImage: Bool? = nil,
        defaultImage: DefaultImageOption? = nil,
        processingMethod: ImageProcessingMethod? = nil
    ) -> Self {
        GravatarImageDownloadOptions(
            scaleFactor: scaleFactor ?? self.scaleFactor,
            preferredSize: preferredSize ?? self.preferredSize,
            rating: rating ?? self.rating,
            forceRefresh: forceRefresh ?? self.forceRefresh,
            forceDefaultImage: forceDefaultImage ?? self.forceDefaultImage,
            defaultImage: defaultImage ?? self.defaultImage,
            processingMethod: processingMethod ?? self.processingMethod
        )
    }
}
