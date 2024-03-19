import Gravatar
import UIKit

class TestActivityIndicator: ActivityIndicatorProvider {
    var animating = false

    func startAnimatingView() {
        animating = true
    }

    func stopAnimatingView() {
        animating = false
    }

    lazy var view: UIView = {
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        newView.backgroundColor = .blue
        return newView
    }()

    func sizeStrategy(in view: UIView) -> ActivityIndicatorSizeStrategy {
        .intrinsicSize
    }
}
