import Foundation
import UIKit

extension UIColor {
    func isVisible() -> Bool {
        rgbaComponents.alpha > 0
    }

    /// Creates an RGBA from this color
    var rgbaComponents: RGBA {
        RGBA(color: self)
    }
}

class RGBA {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0

    init(color: UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
