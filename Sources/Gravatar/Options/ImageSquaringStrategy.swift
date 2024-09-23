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

public protocol ImageSquaring: Sendable {
    func squared(_ image: UIImage) -> UIImage
}

struct DefaultImageSquarer: ImageSquaring {
    func squared(_ image: UIImage) -> UIImage {
        image.squared()
    }
}

extension UIImage {
    package func isSquare() -> Bool {
        size.height == size.width
    }

    fileprivate func squared() -> UIImage {
        if self.isSquare() {
            return self
        }

        let (height, width) = (size.height, size.width)
        let squareSide = {
            // If there's a side difference of 1~2px in an image smaller then (around) 100px, this will return false.
            if width != height && (abs(width - height) / min(width, height)) < 0.02 {
                // Aspect fill
                return min(height, width)
            }
            // Aspect fit
            return max(height, width)
        }()

        let squareSize = CGSize(width: squareSide, height: squareSide)
        let imageOrigin = CGPoint(x: (squareSide - width) / 2, y: (squareSide - height) / 2)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: squareSize, format: format).image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: squareSize))
            draw(in: CGRect(origin: imageOrigin, size: size))
        }
    }
}
