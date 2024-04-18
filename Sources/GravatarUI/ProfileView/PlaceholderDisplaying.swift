import UIKit

@MainActor
protocol AnimatingPlaceholderDisplaying {
    var color: UIColor { get set }
    var animationColors: [UIColor] { get set }
    func show()
    func hide()
    func startAnimating()
    func stopAnimating()
}

@MainActor
class RectangularPlaceholderDisplayer: AnimatingPlaceholderDisplaying {
    var color: UIColor
    var animationColors: [UIColor]
    var baseView: UIView
    let cornerRadius: CGFloat
    let height: CGFloat
    let widthRatioToParent: CGFloat
    var layoutConstraints: [NSLayoutConstraint] = []
    var isShowing: Bool = false
    private var animator: UIViewPropertyAnimator?

    init(baseView: UIView, color: UIColor, cornerRadius: CGFloat, height: CGFloat, widthRatioToParent: CGFloat, animationColors: [UIColor]) {
        self.color = color
        self.animationColors = animationColors
        self.baseView = baseView
        self.cornerRadius = cornerRadius
        self.height = height
        self.widthRatioToParent = widthRatioToParent
    }
    
    func show() {
        guard !isShowing else { return }
        // Deactivate existing ones if any
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints = baseView.transitionIntoPlaceholderState(color: color, cornerRadius: cornerRadius, height: height, widthRatioToParent: widthRatioToParent)
        NSLayoutConstraint.activate(layoutConstraints)
        isShowing = true
    }
    
    func hide() {
        baseView.resetPlaceholderState(color: .clear)
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints = []
        isShowing = false
    }
    
    func startAnimating() {
        if animator?.isRunning == true { return }
        animator = self.baseView.loopBackgroundColors(colors: animationColors)
    }
    
    func stopAnimating() {
        animator?.stopAnimation(true)
        self.baseView.backgroundColor = color
    }
}

@MainActor
class BackgroundColorPlaceholderDisplayer<T: UIView>: AnimatingPlaceholderDisplaying {
    func show() {
        originalBackgroundColor = baseView.backgroundColor
        baseView.backgroundColor = color
    }
    
    func hide() {
        baseView.backgroundColor = originalBackgroundColor
    }
    
    var color: UIColor
    var animationColors: [UIColor]
    let baseView: T
    var originalBackgroundColor: UIColor? = nil

    init(baseView: T, color: UIColor, animationColors: [UIColor]) {
        self.color = color
        self.animationColors = animationColors
        self.baseView = baseView
    }
    
    func startAnimating() {
        self.baseView.loopBackgroundColors(colors: animationColors)
    }
    
    func stopAnimating() {
        self.baseView.backgroundColor = color
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

class AccountButtonsPlaceholderDisplayer: AnimatingPlaceholderDisplaying {
    var color: UIColor
    var animationColors: [UIColor]
    let containerStackView: UIStackView
    
    func show() {
        removeAllArrangedSubviews()
        [placeholderView(), placeholderView(), placeholderView(), placeholderView()].forEach(containerStackView.addArrangedSubview)
    }
    
    func hide() {
        removeAllArrangedSubviews()
    }
    
    
    func startAnimating() {
        containerStackView.arrangedSubviews.forEach { $0.loopBackgroundColors(colors: animationColors) }
    }
    
    func stopAnimating() {
        containerStackView.arrangedSubviews.forEach { $0.backgroundColor = color }
    }
    
    private func removeAllArrangedSubviews() {
        containerStackView.arrangedSubviews.forEach { view in
            containerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    init(containerStackView: UIStackView, color: UIColor, animationColors: [UIColor]) {
        self.color = color
        self.animationColors = animationColors
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
            let heightConstraint = heightAnchor.constraint(equalToConstant: height)
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
    
    func loopBackgroundColors(withDuration duration: TimeInterval = 0.8, colors: [UIColor]) -> UIViewPropertyAnimator {
        return UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, options: [.repeat, .autoreverse, .curveEaseOut]) {
            colors.forEach { color in
                self.backgroundColor = color
            }
        } completion: { _ in
            
        }

        /*UIView.animate(withDuration: duration, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseOut]) {
            colors.forEach { color in
                self.backgroundColor = color
            }
        }*/
    }
}
