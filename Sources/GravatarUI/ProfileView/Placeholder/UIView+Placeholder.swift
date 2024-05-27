import UIKit

@MainActor
extension UIView {
    func turnIntoPlaceholder(cornerRadius: CGFloat?, height: CGFloat?, widthRatioToParent: CGFloat?) -> [NSLayoutConstraint] {
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

    func resetPlaceholder(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        if cornerRadius == 0 {
            clipsToBounds = false
        }
    }
}
