import UIKit

public protocol ImageSquarer {
    func square(_ image: UIImage) -> UIImage
}

package struct GravatarImageSquarer: ImageSquarer {
    private let threshold: CGFloat

    package init(threshold: CGFloat) {
        self.threshold = threshold.clamp(to: 0 ... 1)
    }

    package func square(_ image: UIImage) -> UIImage {
        if image.isSquare() {
            return image
        }

        let (height, width) = (image.size.height, image.size.width)

        // Determine the side length for the square (aspect fill or fit logic)

        let squareSide = (abs(width - height) / min(width, height)) <= threshold
            ? min(width, height) // Aspect fill
            : max(width, height) // Aspect fit

        let squareSize = CGSize(width: squareSide, height: squareSide)
        let imageOrigin = CGPoint(
            x: (squareSize.width - width) / 2,
            y: (squareSize.height - height) / 2
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale // Respect original image scale
        format.opaque = true

        return UIGraphicsImageRenderer(size: squareSize, format: format).image { context in
            UIColor.black.setFill() // Background color
            context.fill(CGRect(origin: .zero, size: squareSize)) // Fill background

            // Draw the image in the center of the new square context
            image.draw(in: CGRect(origin: imageOrigin, size: image.size))
        }
    }
}

struct NoSquaring: ImageSquarer {
    func square(_ image: UIImage) -> UIImage {
        image
    }
}

extension CGFloat {
    func clamp(to range: ClosedRange<Self>) -> Self {
        CGFloat.minimum(CGFloat.maximum(self, range.lowerBound), range.upperBound)
    }
}
