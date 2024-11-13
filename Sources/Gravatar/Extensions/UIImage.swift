import UIKit

extension UIImage {
    package func isSquare() -> Bool {
        size.height == size.width
    }

    /// Describes how close to square an image's `size` is, by comparing the `shortEdge` and `longEdge` of the image.
    ///
    /// `Squareness` is similar to `Aspect Ratio`, except that all values are in the range `0...1`
    /// - A square UIImage (`100 x 100`) has a `squareness` of `1`
    /// - A UIImage with a `size` of `100 x 200` has a `squareness of `0.5`
    var squareness: CGFloat {
        if isSquare() { // This catches 0x0 images, which would cause a divide-by-zero error
            return 1
        }

        return shortEdge / longEdge
    }

    var shortEdge: CGFloat {
        min(self.size.width, self.size.height)
    }

    var longEdge: CGFloat {
        max(self.size.width, self.size.height)
    }
}
