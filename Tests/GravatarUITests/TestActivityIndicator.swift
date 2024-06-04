import GravatarUI
import UIKit

class TestActivityIndicator: ActivityIndicatorProvider {
    var animating = false
    private(set) var startCount: Int = 0
    private(set) var stopCount: Int = 0

    func startAnimatingView() {
        animating = true
        startCount += 1
    }

    func stopAnimatingView() {
        animating = false
        stopCount += 1
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
