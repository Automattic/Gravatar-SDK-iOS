import UIKit

extension CGFloat {
    fileprivate static let minorDifferenceThreshold: CGFloat = 0.02
}

public protocol ImageSquaring: Sendable {
    func square(_ image: UIImage) -> UIImage
}

struct DefaultImageSquarer: ImageSquaring {
    private let backgroundColor: UIColor

    init(backgroundColor: UIColor = .black) {
        self.backgroundColor = backgroundColor
    }

    func square(_ image: UIImage) -> UIImage {
        image.squared(withBackgroundColor: backgroundColor)
    }
}

extension UIImage {
    package func isSquare() -> Bool {
        size.height == size.width
    }

    fileprivate func squared(withBackgroundColor backgroundColor: UIColor) -> UIImage {
        if isSquare() {
            return self
        }

        let (height, width) = (size.height, size.width)

        // Determine the side length for the square (aspect fill or fit logic)
        let squareSide = (abs(width - height) / min(width, height)) < .minorDifferenceThreshold
            ? min(width, height) // Aspect fill
            : max(width, height) // Aspect fit

        let squareSize = CGSize(width: squareSide, height: squareSide)
        let imageOrigin = CGPoint(
            x: (squareSize.width - width) / 2,
            y: (squareSize.height - height) / 2
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale // Respect original image scale
        format.opaque = true

        return UIGraphicsImageRenderer(size: squareSize, format: format).image { context in
            backgroundColor.setFill() // Background color
            context.fill(CGRect(origin: .zero, size: squareSize)) // Fill background

            // Draw the image in the center of the new square context
            self.draw(in: CGRect(origin: imageOrigin, size: size))
        }
    }
}
