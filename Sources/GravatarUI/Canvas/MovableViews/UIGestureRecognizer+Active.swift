import Foundation
import UIKit

/// Extension that checks if a gesture recognizer is currently active/inactive
extension UIGestureRecognizer {
    private static let activeStates: [UIGestureRecognizer.State] = [.began, .changed, .recognized]
    private static let inactiveStates: [UIGestureRecognizer.State] = [.ended, .possible, .failed, .cancelled]

    var isActive: Bool {
        UIGestureRecognizer.activeStates.contains(state)
    }

    var isInactive: Bool {
        UIGestureRecognizer.inactiveStates.contains(state)
    }
}
