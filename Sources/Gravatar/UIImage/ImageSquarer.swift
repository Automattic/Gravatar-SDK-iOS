import UIKit

struct ImageSquarer {
    private let aspectFillMinSquareness: CGFloat

    init(aspectFillMinSquareness: CGFloat) {
        self.aspectFillMinSquareness = aspectFillMinSquareness.clamp(to: 0 ... 1)
    }

    func square(_ image: UIImage) -> UIImage {
        if image.isSquare() {
            return image
        }

        let (height, width) = (image.size.height, image.size.width)

        // Determine the side length for the square (aspect fill or fit logic)

        // Floating point comparisons can be affected by precision issues. But with a maximum image
        // size of `2048 x 2048`, the largest and smallest possible `squareness` values only rely on
        // four decimal places of precision. So this should be a safe comparison.
        let squareSide = image.squareness >= aspectFillMinSquareness
            ? image.shortEdge // Aspect fill
            : image.longEdge // Aspect fit

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

extension CGFloat {
    func clamp(to range: ClosedRange<Self>) -> Self {
        CGFloat.minimum(CGFloat.maximum(self, range.lowerBound), range.upperBound)
    }
}
