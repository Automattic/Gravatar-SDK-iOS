import UIKit

@MainActor
protocol PlaceholderDisplaying {
    func show()
    func hide()
    var color: UIColor { get }
}

@MainActor
class RectangularPlaceholderDisplayer: PlaceholderDisplaying {
    
    let color: UIColor
    let baseView: UIView
    let cornerRadius: CGFloat
    let height: CGFloat
    let widthRatioToParent: CGFloat
    var layoutConstraints: [NSLayoutConstraint] = []
    
    init(baseView: UIView, color: UIColor, cornerRadius: CGFloat, height: CGFloat, widthRatioToParent: CGFloat) {
        self.color = color
        self.baseView = baseView
        self.cornerRadius = cornerRadius
        self.height = height
        self.widthRatioToParent = widthRatioToParent
    }
    
    func show() {
        layoutConstraints = baseView.transitionIntoPlaceholderState(color: color, cornerRadius: cornerRadius, height: height, widthRatioToParent: widthRatioToParent)
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func hide() {
        baseView.resetPlaceholderState(color: .clear)
        NSLayoutConstraint.deactivate(layoutConstraints)
    }
}

@MainActor
class BackgroundColorPlaceholderDisplayer<T: UIView>: PlaceholderDisplaying {
    func show() {
        originalBackgroundColor = baseView.backgroundColor
        baseView.backgroundColor = color
    }
    
    func hide() {
        baseView.backgroundColor = originalBackgroundColor
    }
    
    var color: UIColor
    let baseView: T
    var originalBackgroundColor: UIColor? = nil

    init(baseView: T, color: UIColor) {
        self.color = color
        self.baseView = baseView
    }
}

@MainActor
class ImageViewPlaceholderDisplayer: BackgroundColorPlaceholderDisplayer<UIImageView> {
    private var image: UIImage? = nil
    
    override func show() {
        super.show()
        image = baseView.image
        baseView.image = nil
    }
    
    override func hide() {
        super.hide()
        baseView.image = image
    }
}

class AccountButtonsPlaceholderDisplayer: PlaceholderDisplaying {
    var color: UIColor
    let containerStackView: UIStackView
    
    func show() {
        removeAllArrangedSubviews()
        [placeholderView(), placeholderView(), placeholderView(), placeholderView()].forEach(containerStackView.addArrangedSubview)
    }
    
    func hide() {
        removeAllArrangedSubviews()
    }
    
    private func removeAllArrangedSubviews() {
        containerStackView.arrangedSubviews.forEach { view in
            containerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    init(containerStackView: UIStackView, color: UIColor) {
        self.color = color
        self.containerStackView = containerStackView
    }
    
    private func placeholderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength),
            view.widthAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength)
        ])
        view.layer.cornerRadius = BaseProfileView.Constants.accountIconLength / 2
        view.clipsToBounds = true
        return view
    }
}

@MainActor
extension UIView {
    
    func transitionIntoPlaceholderState(color: UIColor, cornerRadius: CGFloat?, height: CGFloat?, widthRatioToParent: CGFloat?) -> [NSLayoutConstraint] {
        backgroundColor = color
        if let cornerRadius {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
        var constraints: [NSLayoutConstraint] = []
        
        if let height {
            var heightConstraint = heightAnchor.constraint(equalToConstant: height)
            heightConstraint.priority = .required
            constraints.append(heightConstraint)
        }
        
        if let widthRatioToParent, let superview  {
            let widthConstraint = widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: widthRatioToParent)
            widthConstraint.priority = .required
            constraints.append(widthConstraint)
        }
        return constraints
    }
    
    func resetPlaceholderState(resetCornerRadius: Bool = true, color: UIColor) {
        if resetCornerRadius {
            layer.cornerRadius = 0
            clipsToBounds = false
        }
        backgroundColor = color
    }
}
