import Foundation
import UIKit

/// Download options to use outside of `GravatarCompatible` UI components. Refer to `ImageSettingOption`.
public struct ImageDownloadOptions {
    let forceRefresh: Bool
    let processingMethod: ImageProcessingMethod
    public let avatarQueryOptions: AvatarQueryOptions

    private let preferredSize: ImageSize?

    /// Creates a new `GravatarImageDownloadOptions` with the given options.
    ///
    /// When passing `nil` to the optional parameters, the backend defaults are going to be used.
    /// For more info about backend defaults, see https://docs.gravatar.com/general/images/
    /// - Parameters:
    ///   - preferredSize: Preferred image size (set to `nil` for default size)
    ///   - gravatarRating: Maximum rating for image (set to `nil` for default rating)
    ///   - forceRefresh: Force the image to be downloaded, ignoring the cache
    ///   - forceDefaultAvatar: If `true`, the returned image will always be the default avatar, determined by the `defaultAvatarOption` parameter.
    ///   - defaultAvatarOption: Configure the default avatar (set to `nil` to use the default default avatar)
    ///   - processingMethod: Method to use for processing the downloaded `Data`
    public init(
        preferredSize: ImageSize? = nil,
        rating: Rating? = nil,
        forceRefresh: Bool = false,
        forceDefaultAvatar: Bool? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        processingMethod: ImageProcessingMethod = .common(),
        newThing: String
    ) {
        self.forceRefresh = forceRefresh
        self.processingMethod = processingMethod
        self.preferredSize = preferredSize

        self.avatarQueryOptions = AvatarQueryOptions(
            preferredSize: preferredSize,
            rating: rating,
            defaultAvatarOption: defaultAvatarOption,
            forceDefaultAvatar: forceDefaultAvatar
        )
    }
}
