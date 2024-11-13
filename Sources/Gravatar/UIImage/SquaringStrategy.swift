import UIKit

public enum SquaringStrategy {
    case crop(behavior: CroppingBehavior)
    case custom(strategy: ImageSquarer)
    case `default`
    case none

    package var square: (UIImage) -> UIImage {
        let squarer: ImageSquarer = switch self {
        case .crop(let behavior):
            GravatarImageSquarer(threshold: behavior.threshold)
        case .custom(let strategy):
            strategy
        case .default:
            GravatarImageSquarer(threshold: .defaultThreshold)
        case .none:
            NoSquaring()
        }

        return squarer.square(_:)
    }
}

public enum CroppingBehavior {
    case aspectFill
    case aspectFit
    case threshold(CGFloat)
    case `default`

    var threshold: CGFloat {
        switch self {
        case .aspectFill:
            .aspectFillThreshold
        case .aspectFit:
            .aspectFitThreshold
        case .threshold(let value):
            value
        case .default:
            .defaultThreshold
        }
    }
}

extension CGFloat {
    public static let defaultThreshold: CGFloat = 0.02
    public static let aspectFitThreshold: CGFloat = 0.0
    public static let aspectFillThreshold: CGFloat = 1.0
}
