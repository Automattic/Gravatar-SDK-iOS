import UIKit

@MainActor
/// Defines the different types of avatars that can be passed to the `BaseProfileView` subclasses.
public enum AvatarType {
    /// Avatar is a `UIImageView` or a subclass of it.
    /// If `skipStyling` is `true` then no size & shape & border changes will be applied to the `UIImageView` so the appearance needs to be managed externally.
    case imageView(UIImageView, skipStyling: Bool = false)

    /// Avatar is a `UIView` that has a `UIImageView` and its appearance needs to be managed externally.
    case imageViewWrapper(ImageViewWrapper)

    /// Avatar is a custom `UIView` whose appearance is fully managed externally.
    case custom(AvatarProviding)

    var imageView: UIImageView? {
        switch self {
        case .imageView(let imageView, _):
            imageView
        case .imageViewWrapper(let wrapper):
            wrapper.imageView
        case .custom:
            nil
        }
    }
    
    var shouldApplyStyling: Bool {
        switch self {
        case let .imageView(_, skipStyling):
            return !skipStyling
        case .imageViewWrapper, .custom:
            return false
        }
    }

    func avatarProvider(avatarLength: CGFloat, paletteType: PaletteType) -> AvatarProviding {
        switch self {
        case .imageView(let imageView, let skipStyling):
            DefaultAvatarProvider(baseView: imageView, avatarImageView: imageView, skipStyling: skipStyling, avatarLength: avatarLength, paletteType: paletteType)
        case .imageViewWrapper(let wrapper):
            DefaultAvatarProvider(baseView: wrapper.baseView, avatarImageView: wrapper.imageView, skipStyling: true, avatarLength: avatarLength, paletteType: paletteType)
        case .custom(let provider):
            provider
        }
    }
}

/// Defines a UIView that has a UIImageView subview.
@MainActor
public protocol ImageViewWrapper {
    // The `UIImageView` to display the avatar.
    var imageView: UIImageView { get }

    /// The parent view for the imageView. It doesn't have to be the direct parent.
    var baseView: UIView { get }
}

/// Provides a UIView to be used as the avatar in a `BaseProfileView`. This is for taking full control over the avatar..
@MainActor
public protocol AvatarProviding {
    /// `UIView` to insert into the avatar's slot in a `BaseProfileView`.
    var avatarView: UIView { get }

    /// `BaseProfileView` calls this method to load the avatar from a URL.
    /// You may not need to implement this method if the image is downloaded else where.
    func setImage(with source: URL?, placeholder: UIImage?, options: [ImageSettingOption]?, completion: ((Bool) -> Void)?)

    /// Sets the given image as the avatar.
    /// - Parameter image: `UIImage` to set as the avatar. If `nil` then the avatar image should be cleared.
    func setImage(_ image: UIImage?)

    /// Refreshes the `avatarView`'s colors with the given `PaletteType`.
    /// - Parameter paletteType: paletteType to use. See: ``PaletteType``.
    func refresh(with paletteType: PaletteType)
}
