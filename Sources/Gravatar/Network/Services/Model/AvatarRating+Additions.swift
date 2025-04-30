import Foundation

extension AvatarRating {
    package func toRating() -> Rating {
        switch self {
        case .g:
            .general
        case .pg:
            .parentalGuidance
        case .r:
            .restricted
        case .x:
            .x
        }
    }
}
