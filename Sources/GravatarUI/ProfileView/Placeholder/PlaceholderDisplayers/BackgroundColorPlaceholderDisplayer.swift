import UIKit

/// This ``PlaceholderDisplaying`` implementation updates the background color when `showPlaceholder()` is called.
@MainActor
class BackgroundColorPlaceholderDisplayer<T: UIView>: PlaceholderDisplaying {
    var placeholderColor: UIColor
    let baseView: T
    let isTemporary: Bool
    var originalBackgroundColor: UIColor

    init(baseView: T, color: UIColor, originalBackgroundColor: UIColor, isTemporary: Bool = false) {
        self.placeholderColor = color
        self.baseView = baseView
        self.isTemporary = isTemporary
        self.originalBackgroundColor = originalBackgroundColor
    }

    func showPlaceholder() {
        if isTemporary {
            baseView.isHidden = false
        }
        set(viewColor: placeholderColor)
    }

    func hidePlaceholder() {
        set(layerColor: .clear)
        set(viewColor: originalBackgroundColor)
        if isTemporary {
            baseView.isHidden = true
        }
    }

    func set(viewColor newColor: UIColor?) {
        // UIColor can automatically adjust according to `UIUserInterfaceStyle`, but CGColor can't.
        // That's why we can't just rely on `layer.backgroundColor`. We need to set this.
        baseView.backgroundColor = newColor
    }

    func set(layerColor newColor: UIColor?) {
        // backgroundColor is not animatable for some UIView subclasses. For example: UILabel. So we need to animate over `layer.backgroundColor`.
        baseView.layer.backgroundColor = newColor?.cgColor
    }

    func animationWillBegin() {}
    func animationDidEnd() {}
}

@MainActor
class AvatarPlaceholderDisplayer<T: UIView>: BackgroundColorPlaceholderDisplayer<T> {
    private var originalBorderWidth: CGFloat = 0

    override func showPlaceholder() {
        super.showPlaceholder()
        originalBorderWidth = baseView.layer.borderWidth
        baseView.layer.borderWidth = 0
    }

    override func hidePlaceholder() {
        super.hidePlaceholder()
        baseView.layer.borderWidth = originalBorderWidth
    }
}
