import UIKit

/// A ``PlaceholderDisplaying`` implementation for a UILabel.
@MainActor
class LabelPlaceholderDisplayer: RectangularPlaceholderDisplayer<UILabel> {
    var isAnimating: Bool = false

    override func animationDidEnd() {
        isAnimating = false
    }

    override func animationWillBegin() {
        // If UILabel's backgroundColor is set, the animation won't be visible. So we need to clear it. This is only needed for UILabel so far.
        set(viewColor: .clear)
        isAnimating = true
    }

    override func set(viewColor newColor: UIColor?) {
        if !isAnimating {
            // If UILabel's backgroundColor is set, the animation won't be visible.
            // So prevent setting it if there's an animation in progress.
            super.set(viewColor: newColor)
        }
    }
}
