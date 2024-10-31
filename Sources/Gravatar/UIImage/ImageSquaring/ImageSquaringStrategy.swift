import UIKit

public enum ImageSquaringStrategy: Sendable {
    case custom(cropper: ImageSquaring)
    case customBackgroundColor(UIColor)
    case `default`
}

extension ImageSquaringStrategy {
    public var strategy: ImageSquaring {
        switch self {
        case .default:
            DefaultImageSquarer()
        case .customBackgroundColor(let backgroundColor):
            DefaultImageSquarer(backgroundColor: backgroundColor)
        case .custom(cropper: let cropper):
            cropper
        }
    }
}
