import UIKit

/// Set of options which will be used to request the image to the Gravatar backend.
///
/// For the options not specified, the backend defaults will be used.
/// For more information, see the [Gravatar developer documentation](https://docs.gravatar.com/general/images/).
public struct ImageQueryOptions {
    let rating: ImageRating?
    let forceDefaultImage: Bool?
    let defaultImage: DefaultImageOption?
    let preferredPixelSize: Int?

    /// Creating an instance of `ImageQueryOptions`.
    ///
    /// For the options not specified, the backend defaults will be used.
    /// - Parameters:
    ///   - preferredSize: The preferred image size. Note that many users have lower resolution images, so requesting larger sizes may result in
    /// pixelation/low-quality images.
    ///   - gravatarRating: The lowest rating allowed to be displayed. If the requested email hash does not have an image meeting the requested rating level,
    ///   - defaultImage: Choose what will happen if no Gravatar image is found. See ``DefaultImageOption`` for more info.
    /// then the default image is returned.
    ///   - forceDefaultImage: If set to `true`, the requested image will always be the default.
    public init(
        preferredSize: ImageSize? = nil,
        rating: ImageRating? = nil,
        defaultImage: DefaultImageOption? = nil,
        forceDefaultImage: Bool? = nil
    ) {
        self.init(
            scaleFactor: UIScreen.main.scale,
            rating: rating,
            forceDefaultImage: forceDefaultImage,
            defaultImage: defaultImage,
            preferredSize: preferredSize
        )
    }

    init(
        scaleFactor: CGFloat,
        rating: ImageRating? = nil,
        forceDefaultImage: Bool? = nil,
        defaultImage: DefaultImageOption? = nil,
        preferredSize: ImageSize? = nil
    ) {
        self.rating = rating
        self.forceDefaultImage = forceDefaultImage
        self.defaultImage = defaultImage

        switch preferredSize {
        case .pixels(let pixels):
            preferredPixelSize = pixels
        case .points(let points):
            preferredPixelSize = Int(points * scaleFactor)
        case .none:
            preferredPixelSize = nil
        }
    }
}
