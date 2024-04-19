import UIKit

/// Describes a UI element that can show a placeholder with a specific color.
@MainActor
public protocol PlaceholderDisplaying {
    // If 'true', the placeholder element(or elements) will be made visible when `showPlaceholder()` is called, and will be hidden when `hidePlaceholder()` is
    // called.
    var isTemporary: Bool { get }
    /// Color of the placeholder state.
    var color: UIColor { get set }
    /// Shows the placeholder state of this object.
    func showPlaceholder()
    /// Hides the placeholder state of this object. Reverts any changes made by `showPlaceholder()`.
    func hidePlaceholder()
    /// Sets the color of the underlying view element.
    func set(viewColor color: UIColor?)
}

/// This ``PlaceholderDisplaying`` implementation updates the background color when `showPlaceholder()` is called.
@MainActor
class BackgroundColorPlaceholderDisplayer<T: UIView>: PlaceholderDisplaying {
    var color: UIColor
    let baseView: T
    let isTemporary: Bool
    let resetBackgroundColor: UIColor

    init(baseView: T, color: UIColor, resetBackgroundColor: UIColor = .clear, isTemporary: Bool = false) {
        self.color = color
        self.baseView = baseView
        self.isTemporary = isTemporary
        self.resetBackgroundColor = resetBackgroundColor
    }

    func showPlaceholder() {
        if isTemporary {
            baseView.isHidden = false
        }
        set(viewColor: color)
    }

    func hidePlaceholder() {
        set(viewColor: resetBackgroundColor)
        if isTemporary {
            baseView.isHidden = true
        }
    }

    func set(viewColor newColor: UIColor?) {
        // Set to "layer.backgroundColor" because in some UIView subclasses the normal backgroundColor is not animatable. I observed some problems in UILabel,
        // UIButton.
        baseView.layer.backgroundColor = newColor?.cgColor
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
    var color: UIColor
    private let containerStackView: UIStackView
    let isTemporary: Bool
    init(containerStackView: UIStackView, color: UIColor, isTemporary: Bool = false) {
        self.color = color
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
        view.layer.backgroundColor = color.cgColor
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength),
            view.widthAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength),
        ])
        view.layer.cornerRadius = BaseProfileView.Constants.accountIconLength / 2
        view.clipsToBounds = true
        return view
    }

    func set(viewColor color: UIColor?) {
        for arrangedSubview in containerStackView.arrangedSubviews {
            // Set to "layer.backgroundColor", for animation consistency with other views.
            arrangedSubview.layer.backgroundColor = color?.cgColor
        }
    }
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
