import UIKit

extension UIImage {
    package func isSquare() -> Bool {
        size.height == size.width
    }
}
