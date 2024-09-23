import UIKit

public enum ImageSquaringStrategy: Sendable {
    case custom(cropper: ImageSquaring)
    case `default`
}

extension ImageSquaringStrategy {
    public var strategy: ImageSquaring {
        switch self {
        case .default:
            DefaultImageSquarer()
        case .custom(cropper: let cropper):
            cropper
        }
    }
}
