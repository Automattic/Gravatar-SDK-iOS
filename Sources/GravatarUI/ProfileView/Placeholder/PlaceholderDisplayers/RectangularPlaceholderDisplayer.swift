import UIKit

/// A ``PlaceholderDisplaying`` implementation that Inherits ``BackgroundColorPlaceholderDisplayer`.
/// In addition to ``BackgroundColorPlaceholderDisplayer``, this  gives a size to the ui element and rounds its corners a bit when `showPlaceholder()` is
/// called.
@MainActor
class RectangularPlaceholderDisplayer<T: UIView>: BackgroundColorPlaceholderDisplayer<T> {
    fileprivate let cornerRadius: CGFloat
    fileprivate let height: CGFloat
    private let widthRatioToParent: CGFloat
    fileprivate var layoutConstraints: [NSLayoutConstraint] = []
    fileprivate var isShowing: Bool = false
    fileprivate var originalCornerRadius: CGFloat

    init(
        baseView: T,
        color: UIColor,
        originalBackgroundColor: UIColor = .clear,
        cornerRadius: CGFloat,
        height: CGFloat,
        widthRatioToParent: CGFloat,
        isTemporary: Bool = false
    ) {
        self.cornerRadius = cornerRadius
        self.height = height
        self.widthRatioToParent = widthRatioToParent
        self.originalCornerRadius = baseView.layer.cornerRadius
        super.init(baseView: baseView, color: color, originalBackgroundColor: originalBackgroundColor, isTemporary: isTemporary)
    }

    override func showPlaceholder() {
        super.showPlaceholder()
        guard !isShowing else { return }
        // Deactivate existing ones
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints = baseView.turnIntoPlaceholder(cornerRadius: cornerRadius, height: height, widthRatioToParent: widthRatioToParent)
        NSLayoutConstraint.activate(layoutConstraints)
        isShowing = true
    }

    override func hidePlaceholder() {
        super.hidePlaceholder()
        baseView.resetPlaceholder(cornerRadius: originalCornerRadius)
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints = []
        isShowing = false
    }
}

@MainActor
class ConstantSizeRectangularPlaceholderDisplayer<T: UIView>: RectangularPlaceholderDisplayer<T> {
    
    fileprivate let width: CGFloat
    
    init(baseView: T, color: UIColor, originalBackgroundColor: UIColor = .clear, cornerRadius: CGFloat, height: CGFloat, width: CGFloat, isTemporary: Bool = false) {
        self.width = width
        super.init(baseView: baseView, color: color, originalBackgroundColor: originalBackgroundColor, cornerRadius: cornerRadius, height: height, widthRatioToParent: 0, isTemporary: isTemporary)
    }

    override func showPlaceholder() {
        super.showPlaceholder()
        guard !isShowing else { return }
        // Deactivate existing ones
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints = baseView.turnIntoPlaceholder(cornerRadius: cornerRadius, height: height, width: width)
        NSLayoutConstraint.activate(layoutConstraints)
        isShowing = true
    }

}
