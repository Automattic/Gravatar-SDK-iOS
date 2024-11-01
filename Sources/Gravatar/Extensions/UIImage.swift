import UIKit

extension UIImage {
    package func isSquare() -> Bool {
        size.height == size.width
    }

    package func squared(cropToFitThreshold: CGFloat? = 0.02) -> UIImage {
        if isSquare() {
            return self
        }

        guard let cropToFitThreshold else {
            return self
        }

        let (height, width) = (size.height, size.width)

        // Determine the side length for the square (aspect fill or fit logic)

        let squareSide = (abs(width - height) / min(width, height)) <= cropToFitThreshold
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
            UIColor.black.setFill() // Background color
            context.fill(CGRect(origin: .zero, size: squareSize)) // Fill background

            // Draw the image in the center of the new square context
            self.draw(in: CGRect(origin: imageOrigin, size: size))
        }
    }
}
