import Foundation

/// To avoid name conflicts between `Rating` and `Avatar.Rating`
package typealias ImageRating = Rating

extension Avatar: AvatarDetails {
    package var imageID: ImageID {
        imageId
    }

    package var imageURL: String {
        imageUrl
    }

    package var imageRating: ImageRating {
        switch rating {
        case .g:
            ImageRating.general
        case .pg:
            ImageRating.parentalGuidance
        case .r:
            ImageRating.restricted
        case .x:
            ImageRating.x
        }
    }
}
