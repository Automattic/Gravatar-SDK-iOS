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
    case imageCache(GravatarImageCaching)

    /// A custom image downloader. Defaults to `GravatarimageDownloader` if not set.
    case imageDownloader(ImageDownloader)
}

/// Parsed options derived from [GravatarImageSettingOption]
public struct GravatarImageSettingOptions {
    var transition: GravatarImageTransition = .none
    var removeCurrentImageWhileLoading = false
    var forceRefresh = false
    var processingMethod: ImageProcessingMethod = .common
    var imageCache: GravatarImageCaching = GravatarImageCache.shared
    var imageDownloader: ImageDownloader? = nil

    init(options: [GravatarImageSettingOption]?) {
        guard let options = options else { return }
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
    
    func deriveDownloadOptions(garavatarRating rating: GravatarRating? = nil, preferredSize size: ImageSize? = nil) -> GravatarImageDownloadOptions {
        return GravatarImageDownloadOptions(
            preferredSize: size,
            gravatarRating: rating,
            forceRefresh: forceRefresh,
            processingMethod: processingMethod
        )
    }
}

/// Download options to use outside of `GravatarCompatible` UI components. Refer to `GravatarImageSettingOption`.
public struct GravatarImageDownloadOptions {
    let gravatarRating: GravatarRating?
    let forceRefresh: Bool
    let forceDefaultImage: Bool
    let defaultImage: DefaultImageOption?
    let processingMethod: ImageProcessingMethod
    let preferredPixelSize: Int?

    private let preferredSize: ImageSize?
    private let scaleFactor: CGFloat

    public init(
        preferredSize: ImageSize? = nil,
        gravatarRating: GravatarRating? = nil,
        forceRefresh: Bool = false,
        forceDefaultImage: Bool = false,
        defaultImage: DefaultImageOption? = nil,
        processingMethod: ImageProcessingMethod = .common
    ) {
        self.init(
            scaleFactor: UIScreen.main.scale,
            preferredSize: preferredSize,
            gravatarRating: gravatarRating,
            forceRefresh: forceRefresh,
            forceDefaultImage: forceDefaultImage,
            defaultImage: defaultImage,
            processingMethod: processingMethod
        )
    }

    private init(
        scaleFactor: CGFloat,
        preferredSize: ImageSize? = nil,
        gravatarRating: GravatarRating? = nil,
        forceRefresh: Bool = false,
        forceDefaultImage: Bool = false,
        defaultImage: DefaultImageOption? = nil,
        processingMethod: ImageProcessingMethod
    ) {
        self.gravatarRating = gravatarRating
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
        gravatarRating: GravatarRating? = nil,
        forceRefresh: Bool? = nil,
        forceDefaultImage: Bool? = nil,
        defaultImage: DefaultImageOption? = nil,
        processingMethod: ImageProcessingMethod? = nil
    ) -> Self {
        GravatarImageDownloadOptions(
            scaleFactor: scaleFactor ?? self.scaleFactor,
            preferredSize: preferredSize ?? self.preferredSize,
            gravatarRating: gravatarRating ?? self.gravatarRating,
            forceRefresh: forceRefresh ?? self.forceRefresh,
            forceDefaultImage: forceDefaultImage ?? self.forceDefaultImage,
            defaultImage: defaultImage ?? self.defaultImage,
            processingMethod: processingMethod ?? self.processingMethod
        )
    }
}
