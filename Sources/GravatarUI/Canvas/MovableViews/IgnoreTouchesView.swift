import Foundation
import UIKit

/// View that transmit touches in the following way:
/// * if the touch was in a subview, the subview responds;
/// * if the touch was in an "empty" space, the touch moves on
/// in the hierarchy of views to some other (parent or brother, or brother's subview)
/// that may respond to that touch.
/// This class is meant to be subclassed.
class IgnoreTouchesView: UIView {
    /// Override this property to specifically select which types of events to ignore
    private(set) var ignoredTypes: [UIEvent.EventType]? = nil

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        let ignored: Bool = if let type = event?.type, let ignoredTypes {
            ignoredTypes.contains(type)
        } else {
            true
        }
        if ignored {
            return hitView == self ? nil : hitView
        } else {
            return hitView
        }
    }
}
