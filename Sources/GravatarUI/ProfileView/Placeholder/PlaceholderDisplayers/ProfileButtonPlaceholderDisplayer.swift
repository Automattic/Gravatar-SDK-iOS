import UIKit

/// A ``PlaceholderDisplaying`` implementation for the "Edit/View profile" button.
@MainActor
class ProfileButtonPlaceholderDisplayer: RectangularPlaceholderDisplayer<UIButton> {
    
    override func showPlaceholder() {
        super.showPlaceholder()
        baseView.imageView?.isHidden = true
        baseView.titleLabel?.isHidden = true
    }
    
    override func hidePlaceholder() {
        super.hidePlaceholder()
        baseView.imageView?.isHidden = false
        baseView.titleLabel?.isHidden = false
    }
}

