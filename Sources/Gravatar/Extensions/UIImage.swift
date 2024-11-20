import UIKit

extension UIImage {
    package var isSquare: Bool {
        size.height == size.width
    }

    var aspectRatio: CGFloat {
        size.width / size.height
    }

    /// Describes how close to square an image's `size` is, by comparing the `shortEdge` and `longEdge` of the image.
    ///
    /// `Squareness` is similar to `Aspect Ratio`, except that all values are in the range `0...1`
    /// - A square UIImage (`100 x 100`) has a `squareness` of `1`
    /// - A UIImage with a `size` of `100 x 200` has a `squareness of `0.5`
    ///
    /// - SeeAlso: ``SquaringStrategy``
    var squareness: CGFloat {
        if isSquare { // This catches 0x0 images, which would cause a divide-by-zero error
            return 1
        }

        return shortEdge / longEdge
    }

    var deviationFromSquare: CGFloat {
        1 - squareness
    }

    /// Returns the lenght of the shorter edge of an image
    var shortEdge: CGFloat {
        min(self.size.width, self.size.height)
    }

    /// Returns the length of the longer edge of an image
    var longEdge: CGFloat {
        max(self.size.width, self.size.height)
    }

    package func squared(
        aboveThreshold squarenessThreshold: CGFloat = .defaultSquarenessTolerance,
        maxSize: ImageSize? = nil
    ) -> UIImage {
        self
            .squared(aboveThreshold: squarenessThreshold)
            .resized(toMaxSize: maxSize)
    }

    package func squared(aboveThreshold squarenessThreshold: CGFloat) -> UIImage {
        guard !self.isSquare, self.deviationFromSquare <= squarenessThreshold.clamped(to: 0 ... 1.0) else { return self }

        let (height, width) = (self.size.height, self.size.width)

        let squareSideLength = floor(self.shortEdge)

        let squareSize = CGSize(width: squareSideLength, height: squareSideLength)
        let imageOrigin = CGPoint(
            x: (squareSize.width - width) / 2,
            y: (squareSize.height - height) / 2
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale // Respect original image scale

        return UIGraphicsImageRenderer(size: squareSize, format: format).image { _ in
            // Draw the image in the center of the new square context
            self.draw(in: CGRect(origin: imageOrigin, size: self.size))
        }
    }

    package func resized(toMaxSize maxSize: ImageSize?) -> UIImage {
        guard let maxSize else { return self }

        let maxLengthInPoints = maxSize.points(scaleFactor: self.scale)

        guard maxLengthInPoints > 0, longEdge > maxLengthInPoints else { return self }

        let newSize = if aspectRatio > 1 {
            CGSize(
                width: maxLengthInPoints,
                height: maxLengthInPoints / aspectRatio
            )
        } else {
            CGSize(
                width: maxLengthInPoints * aspectRatio,
                height: maxLengthInPoints
            )
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale

        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension CGFloat {
    package static let defaultSquarenessTolerance: CGFloat = 0.02
}
