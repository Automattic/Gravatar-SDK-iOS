import Foundation
import UIKit

/// Protocol for the view inside MovableView
@MainActor
protocol MovableViewInnerElement: UIView, NSSecureCoding {
    /// Checks whether the hit is done inside the shape of the view
    ///
    /// - Parameter point: location where the view was touched
    /// - Returns: true if the touch was inside, false if not
    func hitInsideShape(point: CGPoint) -> Bool

    var viewSize: CGSize { get set }

    var viewCenter: CGPoint { get set }
}
