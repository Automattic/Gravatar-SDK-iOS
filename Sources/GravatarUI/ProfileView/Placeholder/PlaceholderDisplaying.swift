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
    /// Prepares for color animations.
    func prepareForAnimation()
    /// Refreshes the color.  `backgroundColor` is set to `placeholderColor` and`layer.backgroundColor` to nil.
    func refreshColor()
}

extension PlaceholderDisplaying {
    func refreshColor() {
        set(layerColor: .clear)
        set(viewColor: placeholderColor)
    }
}

/// This ``PlaceholderDisplaying`` implementation updates the background color when `showPlaceholder()` is called.
@MainActor
class BackgroundColorPlaceholderDisplayer<T: UIView>: PlaceholderDisplaying {
    var placeholderColor: UIColor
    let baseView: T
    let isTemporary: Bool
    let originalBackgroundColor: UIColor

    init(baseView: T, color: UIColor, originalBackgroundColor: UIColor = .clear, isTemporary: Bool = false) {
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
        set(viewColor: originalBackgroundColor)
        set(layerColor: .clear)
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

    func prepareForAnimation() {
        if baseView is UILabel {
            // If UILabel's backgroundColor is set, the animation won't be visible. So we need to clear it. This is only needed for UILabel so far.
            set(viewColor: .clear)
        }
    }
}

/// A ``PlaceholderDisplaying`` implementation that Inherits ``BackgroundColorPlaceholderDisplayer`.
/// In addition to ``BackgroundColorPlaceholderDisplayer``, this  gives a size to the ui element and rounds its corners a bit when `showPlaceholder()` is
/// called.
@MainActor
class RectangularPlaceholderDisplayer<T: UIView>: BackgroundColorPlaceholderDisplayer<T> {
    private let cornerRadius: CGFloat
    private let height: CGFloat
    private let widthRatioToParent: CGFloat
    private var layoutConstraints: [NSLayoutConstraint] = []
    private var isShowing: Bool = false
    private var originalCornerRadius: CGFloat

    init(baseView: T, color: UIColor, cornerRadius: CGFloat, height: CGFloat, widthRatioToParent: CGFloat, isTemporary: Bool = false) {
        self.cornerRadius = cornerRadius
        self.height = height
        self.widthRatioToParent = widthRatioToParent
        self.originalCornerRadius = baseView.layer.cornerRadius
        super.init(baseView: baseView, color: color, isTemporary: isTemporary)
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

/// This ``PlaceholderDisplaying`` implementation is tailored for account buttons. It shows 4 shadow account buttons in the given color.
@MainActor
class AccountButtonsPlaceholderDisplayer: PlaceholderDisplaying {
    var placeholderColor: UIColor
    private let containerStackView: UIStackView
    let isTemporary: Bool
    init(containerStackView: UIStackView, color: UIColor, isTemporary: Bool = false) {
        self.placeholderColor = color
        self.isTemporary = isTemporary
        self.containerStackView = containerStackView
    }

    func showPlaceholder() {
        removeAllArrangedSubviews()
        [placeholderView(), placeholderView(), placeholderView(), placeholderView()].forEach(containerStackView.addArrangedSubview)
        if isTemporary {
            containerStackView.isHidden = false
        }
    }

    func hidePlaceholder() {
        removeAllArrangedSubviews()
        if isTemporary {
            containerStackView.isHidden = true
        }
    }

    private func removeAllArrangedSubviews() {
        for view in containerStackView.arrangedSubviews {
            containerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func placeholderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = placeholderColor
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength),
            view.widthAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength),
        ])
        view.layer.cornerRadius = BaseProfileView.Constants.accountIconLength / 2
        view.clipsToBounds = true
        return view
    }

    func set(viewColor newColor: UIColor?) {
        for arrangedSubview in containerStackView.arrangedSubviews {
            arrangedSubview.backgroundColor = newColor
        }
    }

    func set(layerColor newColor: UIColor?) {
        for arrangedSubview in containerStackView.arrangedSubviews {
            arrangedSubview.layer.backgroundColor = newColor?.cgColor
        }
    }

    func prepareForAnimation() {}
}

@MainActor
extension UIView {
    fileprivate func turnIntoPlaceholder(cornerRadius: CGFloat?, height: CGFloat?, widthRatioToParent: CGFloat?) -> [NSLayoutConstraint] {
        if let cornerRadius {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
        var constraints: [NSLayoutConstraint] = []

        if let height {
            let heightConstraint = heightAnchor.constraint(equalToConstant: height)
            heightConstraint.priority = .required
            constraints.append(heightConstraint)
        }

        if let widthRatioToParent, let superview {
            let widthConstraint = widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: widthRatioToParent)
            widthConstraint.priority = .required
            constraints.append(widthConstraint)
        }
        return constraints
    }

    fileprivate func resetPlaceholder(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        if cornerRadius == 0 {
            clipsToBounds = false
        }
    }
}
