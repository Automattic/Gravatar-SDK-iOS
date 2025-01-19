import UIKit

extension CGRect {
    /// convenience method for setting and getting the center
    var center: CGPoint {
        get {
            CGPoint(
                x: midX,
                y: midY
            )
        }
        set {
            origin.x = newValue.x - (width / 2)
            origin.y = newValue.y - (height / 2)
        }
    }
}
