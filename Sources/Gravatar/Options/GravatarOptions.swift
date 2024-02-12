import Foundation
import UIKit

/// Options to use when fetching a Gravatar profile image and setting it to a `GravatarCompatible` UI component.
public enum GravatarImageSettingOption {
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
    case imageDownloader(ImageServing)
}

// Parsed options derived from [GravatarImageSettingOption]
public struct GravatarImageSettingOptions {
    var transition: GravatarImageTransition = .none
    var removeCurrentImageWhileLoading = false
    var forceRefresh = false
    var processor: GravatarImageProcessor = DefaultImageProcessor.common
    var imageCache: GravatarImageCaching = GravatarImageCache.shared
    var imageDownloader: ImageServing? = nil

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
            case .processor(let imageProcessor):
                processor = imageProcessor
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
            processor: processor
        )
    }
}

// Download options to use outside of `GravatarCompatible` UI components. Refer to `GravatarImageSettingOption`.
public struct GravatarImageDownloadOptions {
    let gravatarRating: GravatarRating?
    let forceRefresh: Bool
    let forceDefaultImage: Bool
    let defaultImage: DefaultImageOption?
    let processor: GravatarImageProcessor
    let preferredPixelSize: Int?

    private let preferredSize: ImageSize?
    private let scaleFactor: CGFloat

    public init(
        preferredSize: ImageSize? = nil,
        gravatarRating: GravatarRating? = nil,
        forceRefresh: Bool = false,
        forceDefaultImage: Bool = false,
        defaultImage: DefaultImageOption? = nil,
        processor: GravatarImageProcessor = DefaultImageProcessor.common
    ) {
        self.init(
            scaleFactor: UIScreen.main.scale,
            preferredSize: preferredSize,
            gravatarRating: gravatarRating,
            forceRefresh: forceRefresh,
            forceDefaultImage: forceDefaultImage,
            defaultImage: defaultImage,
            processor: processor
        )
    }

    private init(
        scaleFactor: CGFloat,
        preferredSize: ImageSize? = nil,
        gravatarRating: GravatarRating? = nil,
        forceRefresh: Bool = false,
        forceDefaultImage: Bool = false,
        defaultImage: DefaultImageOption? = nil,
        processor: GravatarImageProcessor = DefaultImageProcessor.common
    ) {
        self.gravatarRating = gravatarRating
        self.forceRefresh = forceRefresh
        self.forceDefaultImage = forceDefaultImage
        self.processor = processor
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
        processor: GravatarImageProcessor? = nil
    ) -> Self {
        GravatarImageDownloadOptions(
            scaleFactor: scaleFactor ?? self.scaleFactor,
            preferredSize: preferredSize ?? self.preferredSize,
            gravatarRating: gravatarRating ?? self.gravatarRating,
            forceRefresh: forceRefresh ?? self.forceRefresh,
            forceDefaultImage: forceDefaultImage ?? self.forceDefaultImage,
            defaultImage: defaultImage ?? self.defaultImage,
            processor: processor ?? self.processor
        )
    }
}
