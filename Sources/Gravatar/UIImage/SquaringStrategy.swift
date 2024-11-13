import UIKit

public enum SquaringStrategy {
    case aspectFill
    case aspectFit
    case edgeRatioDeterminesFitOrFill(edgeRatio: CGFloat)
    case `default`
    case none

    package func square(_ image: UIImage) -> UIImage {
        switch self {
        case .aspectFit:
            ImageSquarer(edgeRatioThreshold: .aspectFitThreshold).square(image)
        case .aspectFill:
            ImageSquarer(edgeRatioThreshold: .aspectFillThreshold).square(image)
        case .edgeRatioDeterminesFitOrFill(let edgeRatio):
            ImageSquarer(edgeRatioThreshold: edgeRatio).square(image)
        case .default:
            ImageSquarer(edgeRatioThreshold: .defaultThreshold).square(image)
        case .none:
            image
        }
    }
}

extension CGFloat {
    fileprivate static let defaultThreshold: CGFloat = 0.98
    fileprivate static let aspectFitThreshold: CGFloat = 1.0
    fileprivate static let aspectFillThreshold: CGFloat = 0.0
}
