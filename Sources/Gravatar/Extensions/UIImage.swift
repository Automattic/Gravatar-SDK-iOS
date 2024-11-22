import UIKit

extension UIImage {
    package var isSquare: Bool {
        size.height == size.width
    }
}

// MARK: - Internal

extension UIImage {
    /// Crops a `UIImage` to be square if it's `squareness` is above a given `squarenessThreshold`. Images with a `squareness` below the threshold will not be
    /// squared.
    /// - Parameters:
    ///   - squarenessThreshold: The threshold over which images should be squared. Value must be in the closed range `0.0 ... 1.0`
    /// - Returns: A `UIImage` that has been squared according to the threshold
    func squared(aboveThreshold squarenessThreshold: CGFloat = .defaultSquarenessThreshold) -> UIImage {
        assert((0.0 ... 1.0).contains(squarenessThreshold), "Squareness threshold must be between 0 and 1")
        guard !self.isSquare, self.squareness >= squarenessThreshold else { return self }

        let (height, width) = (self.size.height, self.size.width)

        let squareSideLength = self.shortEdge

        let squareSize = CGSize(width: squareSideLength, height: squareSideLength)
        let imageOrigin = CGPoint(
            x: (squareSize.width - width) / 2,
            y: (squareSize.height - height) / 2
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale // Respect original image scale

        return UIGraphicsImageRenderer(size: squareSize, format: format).image { _ in
            // Draw the image in the center of the new square context
            self.draw(in: CGRect(origin: imageOrigin, size: squareSize))
        }
    }

    /// Describes how close to square an image's `size` is, by comparing the `shortEdge` and `longEdge` of the image.
    ///
    /// This returns the same value for the same `UIImage` at different image scales. To account for floating point precision issues introduced when using
    /// points
    /// (`pixels / scale`), this calculation uses the underlying pixel counts (`points * scale`).
    ///
    /// ## Squareness
    /// `Squareness` is similar to `Aspect Ratio`, except that all values are in the range `0...1`
    /// - A square UIImage (`100 x 100`) has a `squareness` of `1`
    /// - A UIImage with a `size` of `100 x 200` has a `squareness of `0.5`
    var squareness: CGFloat {
        if isSquare { // This catches 0x0 images, which would cause a divide-by-zero error
            return 1
        }

        return (shortEdge * scale) / (longEdge * scale)
    }

    /// Returns the lenght of the shorter edge of an image
    var shortEdge: CGFloat {
        min(self.size.width, self.size.height)
    }

    /// Returns the length of the longer edge of an image
    var longEdge: CGFloat {
        max(self.size.width, self.size.height)
    }
}

extension CGFloat {
    /// Default `squarenessThreshold`
    static let defaultSquarenessThreshold: CGFloat = 0.98
}
