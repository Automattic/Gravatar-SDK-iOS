import UIKit

/// A ``PlaceholderDisplaying`` implementation for the "Edit/View profile" button.
@MainActor
class LabelPlaceholderDisplayer: RectangularPlaceholderDisplayer<UILabel> {
    
    override func prepareForAnimation() {
        // If UILabel's backgroundColor is set, the animation won't be visible. So we need to clear it. This is only needed for UILabel so far.
        set(viewColor: .clear)
    }
}
