import UIKit

/// Describes a UI element that can show a placeholder with a specific color.
@MainActor
public protocol PlaceholderDisplaying {
    // If 'true', the placeholder element(or elements) will be made visible when `showPlaceholder()` is called, and will be hidden when `hidePlaceholder()` is
    // called.
    var isTemporary: Bool { get }
    /// Color of the placeholder state.
    var placeholderColor: UIColor { get set }
    /// Shows the placeholder state of this object.
    func showPlaceholder()
    /// Hides the placeholder state of this object. Reverts any changes made by `showPlaceholder()`.
    func hidePlaceholder()
    /// Sets the `layer.backgroundColor` of the underlying view element.
    func set(layerColor newColor: UIColor?)
    /// Sets the `backgroundColor` of the underlying view element.
    func set(viewColor newColor: UIColor?)
    /// Informs the element before the animations begin.
    func animationWillBegin()
    /// Informs the element after the  animations end.
    func animationDidEnd()
    /// Refreshes the color.  `backgroundColor` is set to `placeholderColor` and`layer.backgroundColor` to nil.
    func refreshColor()
}

extension PlaceholderDisplaying {
    func refreshColor() {
        set(layerColor: .clear)
        set(viewColor: placeholderColor)
    }
}
