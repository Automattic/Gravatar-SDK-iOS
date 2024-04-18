import UIKit

@MainActor
public class ProfileViewActivityIndicatorProvider: ActivityIndicatorProvider {
    
    private static let visibleAlpha: CGFloat = 1
    private let colors: [UIColor]
    private var animator: UIViewPropertyAnimator?
    private var isAnimating: Bool = false
    public lazy var view: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(colors: [UIColor]) {
        self.colors = colors
    }
    
    public func startAnimatingView() {
        guard !isAnimating else { return }
        view.alpha = Self.visibleAlpha
        view.isHidden = false
        /*UIView.animate(withDuration: 0.2) {
            self.view.alpha = Self.visibleAlpha
        }*/
        //view.layer.compositingFilter = "darkenBlendMode"
        //view.layer.compositingFilter = "overlayBlendMode"
        //view.layer.compositingFilter = "lightenBlendMode"
        UIView.animate(withDuration: 0.8, delay: 0.0, options: [.repeat, .autoreverse, .curveEaseOut]) {
            self.colors.forEach { color in
                self.view.backgroundColor = color
            }
        }
        /*animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0, options:  [.repeat, .autoreverse, .curveEaseOut]) {
            self.colors.forEach { color in
                self.view.backgroundColor = color
            }
        }
        animator?.startAnimation()*/
        isAnimating = true
    }
    
    public func stopAnimatingView() {
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 0
        } completion: { _ in
            self.animator?.stopAnimation(true)
            self.animator = nil
            self.view.isHidden = true
        }
        isAnimating = false
    }
    
    public func sizeStrategy(in view: UIView) -> ActivityIndicatorSizeStrategy {
        .full
    }
}
