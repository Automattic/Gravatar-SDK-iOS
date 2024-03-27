import UIKit

/// Set of options which will be used to request the avatar from the Gravatar backend.
///
/// For the options not specified, the backend defaults will be used.
/// For more information, see the [Gravatar developer documentation](https://docs.gravatar.com/general/images/).
public struct AvatarQueryOptions {
    let rating: Rating?
    let forceDefaultAvatar: Bool?
    let defaultAvatarOption: DefaultAvatarOption?
    let preferredPixelSize: Int?

    /// Creating an instance of `AvatarQueryOptions`.
    ///
    /// For the options not specified, the backend defaults will be used.
    /// - Parameters:
    ///   - preferredSize: The preferred image size. Note that many users have lower resolution images, so requesting larger sizes may result in
    /// pixelation/low-quality images.
    ///   - gravatarRating: The lowest rating allowed to be displayed. If the requested email hash does not have an image meeting the requested rating level,
    ///   - defaultAvatarOption: Choose what will happen if no Gravatar image is found. See ``DefaultAvatarOption`` for more info.
    /// then the default avatar is returned.
    ///   - forceDefaultAvatar: If set to `true`, the returned image will always be the default avatar, determined by the `defaultAvatarOption` parameter.
    public init(
        preferredSize: ImageSize? = nil,
        rating: Rating? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        forceDefaultAvatar: Bool? = nil
    ) {
        self.init(
            scaleFactor: UI.scaleFactor,
            rating: rating,
            forceDefaultAvatar: forceDefaultAvatar,
            defaultAvatarOption: defaultAvatarOption,
            preferredSize: preferredSize
        )
    }

    init(
        scaleFactor: CGFloat,
        rating: Rating? = nil,
        forceDefaultAvatar: Bool? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        preferredSize: ImageSize? = nil
    ) {
        self.rating = rating
        self.forceDefaultAvatar = forceDefaultAvatar
        self.defaultAvatarOption = defaultAvatarOption
        self.preferredPixelSize = preferredSize?.pixels(scaleFactor: scaleFactor)
    }
}

// MARK: - Converting Query options into URLQueryItems

extension AvatarQueryOptions {
    private enum QueryName: String, CaseIterable {
        case defaultAvatarOption = "d"
        case preferredPixelSize = "s"
        case rating = "r"
        case forceDefaultAvatar = "f"
    }

    var queryItems: [URLQueryItem] {
        QueryName.allCases.compactMap(queryItem)
    }

    private func queryItem(for queryName: QueryName) -> URLQueryItem? {
        let value: String? = switch queryName {
        case .defaultAvatarOption:
            self.defaultAvatarOption.queryValue
        case .forceDefaultAvatar:
            self.forceDefaultAvatar.queryValue
        case .rating:
            self.rating.queryValue
        case .preferredPixelSize:
            self.preferredPixelSize.queryValue
        }

        guard let value else {
            return nil
        }

        return URLQueryItem(name: queryName.rawValue, value: value)
    }
}

extension DefaultAvatarOption? {
    fileprivate var queryValue: String? {
        guard let self else { return nil }

        return self.rawValue
    }
}

extension Rating? {
    fileprivate var queryValue: String? {
        guard let self else { return nil }

        return self.rawValue
    }
}

extension Int? {
    fileprivate var queryValue: String? {
        guard let self else { return nil }

        return String(self)
    }
}

extension Bool? {
    fileprivate var queryValue: String? {
        guard let self else { return nil }

        switch self {
        case true:
            return "y"
        case false:
            return "n"
        }
    }
}
