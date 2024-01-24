import Foundation
import UIKit

/// Options to use when fetching a Gravatar profile image and setting it to a `GravatarCompatible` UI component.
public enum GravatarImageSettingOption {
    // The value is used when converting the retrieved data to an image.
    // Default value is: UIScreen.main.scale. You may set values as `1.0`, `2.0`, `3.0`.
    case scaleFactor(CGFloat)

    // Gravatar Image Ratings. Defaults to: GravatarRatings.default.
    case gravatarRating(GravatarRating)

    // Transition style to use when setting the new image downloaded. Default: .none
    case transition(GravatarImageTransition)

    // Preferred size of the image that will be downloaded. If not provided, layoutIfNeeded() is called on the view to get its bounds properly.
    // You can pass the preferred size to avoid the layoutIfNeeded() call and get a performance benefit.
    case preferredSize(CGSize)

    // By setting this option, the current image will be removed and the placeholder will be shown while downloading the new image.
    case removeCurrentImageWhileLoading

    // Ignore the cached value and re-download the image.
    case forceRefresh

    // Cancels the ongoing download in the view wrapper if a new download starts.
    case cancelOngoingDownload
    
    // Processor to run on the the downloaded data while converting it into an image.
    // If not set `DefaultImageProcessor` will be used.
    case processor(GravatarImageProcessor)
}

// Parsed options derived from [GravatarImageSettingOption]
public struct GravatarImageSettingOptions {
    var scaleFactor: CGFloat = UIScreen.main.scale
    var gravatarRating: GravatarRating = .default
    var transition: GravatarImageTransition = .none
    var preferredSize: CGSize? = nil
    var removeCurrentImageWhileLoading = false
    var forceRefresh = false
    var shouldCancelOngoingDownload = false
    var processor: GravatarImageProcessor = DefaultImageProcessor.common

    init(options: [GravatarImageSettingOption]?) {
        guard let options = options else { return }
        for option in options {
            switch option {
            case .gravatarRating(let rating):
                gravatarRating = rating
            case .scaleFactor(let scale):
                scaleFactor = scale
            case .transition(let imageTransition):
                transition = imageTransition
            case .preferredSize(let size):
                preferredSize = size
            case .removeCurrentImageWhileLoading:
                removeCurrentImageWhileLoading = true
            case .forceRefresh:
                forceRefresh = true
            case .cancelOngoingDownload:
                shouldCancelOngoingDownload = true
            case .processor(let imageProcessor):
                processor = imageProcessor
            }
        }
    }
    
    func deriveDownloadOptions() -> GravatarImageDownloadOptions {
        return GravatarImageDownloadOptions(
            scaleFactor: scaleFactor,
            gravatarRating: gravatarRating,
            preferredSize: preferredSize,
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
