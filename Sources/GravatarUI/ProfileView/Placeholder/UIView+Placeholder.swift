import UIKit

@MainActor
extension UIView {
    private func turnIntoPlaceholder(cornerRadius: CGFloat?, height: CGFloat?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let cornerRadius {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
        if let height {
            let heightConstraint = heightAnchor.constraint(equalToConstant: height)
            heightConstraint.priority = .required
            constraints.append(heightConstraint)
        }
        return constraints
    }
    
    func turnIntoPlaceholder(cornerRadius: CGFloat?, height: CGFloat?, widthRatioToParent: CGFloat?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let widthRatioToParent, let superview {
            let widthConstraint = widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: widthRatioToParent)
            widthConstraint.priority = .required
            constraints.append(widthConstraint)
        }
        return constraints
    }

    func turnIntoPlaceholder(cornerRadius: CGFloat?, height: CGFloat?, width: CGFloat?) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        if let width, let superview {
            let widthConstraint = widthAnchor.constraint(equalToConstant: width)
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
