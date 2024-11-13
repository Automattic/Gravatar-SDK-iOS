import UIKit

extension UIImage {
    package func isSquare() -> Bool {
        size.height == size.width
    }

    package var edgeRatio: CGFloat {
        if isSquare() { // This catches 0x0 images, which would cause a divide-by-zero error
            return 1
        }

        return shortEdge / longEdge
    }

    package var shortEdge: CGFloat {
        min(self.size.width, self.size.height)
    }

    package var longEdge: CGFloat {
        max(self.size.width, self.size.height)
    }
}
