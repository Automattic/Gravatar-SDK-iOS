import UIKit

/// Set of options which will be used to request the image to the Gravatar backend.
///
/// For the options not specified, the backend defaults will be used.
/// For more information, see the [Gravatar developer documentation](https://docs.gravatar.com/general/images/).
public struct ImageQueryOptions {
    let rating: Rating?
    let forceDefaultImage: Bool?
    let defaultAvatarOption: DefaultAvatarOption?
    let preferredPixelSize: Int?

    /// Creating an instance of `ImageQueryOptions`.
    ///
    /// For the options not specified, the backend defaults will be used.
    /// - Parameters:
    ///   - preferredSize: The preferred image size. Note that many users have lower resolution images, so requesting larger sizes may result in
    /// pixelation/low-quality images.
    ///   - gravatarRating: The lowest rating allowed to be displayed. If the requested email hash does not have an image meeting the requested rating level,
    ///   - defaultAvatarOption: Choose what will happen if no Gravatar image is found. See ``DefaultAvatarOption`` for more info.
    /// then the default avatar is returned.
    ///   - forceDefaultImage: If set to `true`, the returned image will always be the default avatar, determined by the `defaultAvatarOption` parameter.
    public init(
        preferredSize: ImageSize? = nil,
        rating: Rating? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        forceDefaultImage: Bool? = nil
    ) {
        self.init(
            scaleFactor: UIScreen.main.scale,
            rating: rating,
            forceDefaultImage: forceDefaultImage,
            defaultAvatarOption: defaultAvatarOption,
            preferredSize: preferredSize
        )
    }

    init(
        scaleFactor: CGFloat,
        rating: Rating? = nil,
        forceDefaultImage: Bool? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        preferredSize: ImageSize? = nil
    ) {
        self.rating = rating
        self.forceDefaultImage = forceDefaultImage
        self.defaultAvatarOption = defaultAvatarOption
        self.preferredPixelSize = preferredSize?.pixels(scaleFactor: scaleFactor)
    }
}

// MARK: - Converting Query options into URLQueryItems

extension ImageQueryOptions {
    private enum QueryName: String, CaseIterable {
        case defaultAvatarOption = "d"
        case preferredPixelSize = "s"
        case rating = "r"
        case forceDefaultImage = "f"
    }

    var queryItems: [URLQueryItem] {
        QueryName.allCases.compactMap(queryItem)
    }

    private func queryItem(for queryName: QueryName) -> URLQueryItem? {
        let value: String? = switch queryName {
        case .defaultAvatarOption:
            self.defaultAvatarOption.queryValue
        case .forceDefaultImage:
            self.forceDefaultImage.queryValue
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
