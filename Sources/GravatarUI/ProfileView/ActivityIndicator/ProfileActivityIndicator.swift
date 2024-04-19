import UIKit

/// Describes a general purpose activity indicator.
@MainActor
public protocol ActivityIndicator {
    associatedtype T: UIView
    func startAnimating(on baseView: T)
    func stopAnimating(on baseView: T)
}

public protocol ProfileActivityIndicator: ActivityIndicator where T == BaseProfileView {}

/// Activity indicator that is designed for `BaseProfileView`.  Animates the backgroundColor of each placeholder element to indicate activity.
@MainActor
class ProfilePlaceholderActivityIndicator: ProfileActivityIndicator {
    let placeholderDisplayer: ProfileViewPlaceholderDisplayer

    private var animator: UIViewPropertyAnimator?
    private var shouldStopAnimating: Bool = false

    init(placeholderDisplayer: ProfileViewPlaceholderDisplayer) {
        self.placeholderDisplayer = placeholderDisplayer
    }

    /// Animates the background colors of each UI element to indicate activity.
    func startAnimating(on baseView: BaseProfileView) {
        // This activity indicator should only work when fields are in their placeholder state.
        guard placeholderDisplayer.isShowing else { return }
        shouldStopAnimating = false
        self.placeholderDisplayer.elements?.forEach { element in
            element.prepareForAnimation()
        }
        doLoadingAnimation(index: 0, animatingColors: baseView.placeholderColors.loadingAnimationColors)
    }

    func stopAnimating(on baseView: BaseProfileView) {
        shouldStopAnimating = true
        if animator?.isRunning == true {
            animator?.stopAnimation(true)
        }
        self.placeholderDisplayer.elements?.forEach { element in
            if placeholderDisplayer.isShowing {
                element.refreshColor()
            }
            else {
                element.hidePlaceholder()
            }
        }
    }

    private func doLoadingAnimation(index: Int, animatingColors: [UIColor]) {
        if shouldStopAnimating { return }
        // The `AnimationOptions.repeat` option doesn't work properly so I am doing my own loop.
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.8, delay: 0, options: [.curveEaseOut]) { [weak self] in
            guard let self else { return }
            let index = index % (animatingColors.count)
            guard index < animatingColors.count,
                  let elements = self.placeholderDisplayer.elements else { return }
            for element in elements {
                element.set(layerColor: animatingColors[index])
            }
        } completion: { [weak self] _ in
            self?.doLoadingAnimation(index: index + 1, animatingColors: animatingColors)
        }
    }
}
