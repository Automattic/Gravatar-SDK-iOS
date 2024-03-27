import Gravatar
import UIKit

class TestActivityIndicator: ActivityIndicatorProvider {
    var animating = false
    var counter: Int = 0
    func startAnimatingView() {
        animating = true
        counter += 1
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
