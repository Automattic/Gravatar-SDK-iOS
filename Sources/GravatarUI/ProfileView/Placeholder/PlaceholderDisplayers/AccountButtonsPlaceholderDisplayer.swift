import UIKit

/// This ``PlaceholderDisplaying`` implementation is tailored for account buttons. It shows 4 shadow account buttons in the given color.
@MainActor
class AccountButtonsPlaceholderDisplayer: PlaceholderDisplaying {
    var placeholderColor: UIColor
    private let containerStackView: UIStackView
    let isTemporary: Bool
    let placeholderTag = 100
    init(containerStackView: UIStackView, color: UIColor, isTemporary: Bool = false) {
        self.placeholderColor = color
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
            if view.tag == placeholderTag {
                containerStackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
    }

    private func placeholderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = placeholderColor
        view.tag = placeholderTag
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength),
            view.widthAnchor.constraint(equalToConstant: BaseProfileView.Constants.accountIconLength),
        ])
        view.layer.cornerRadius = BaseProfileView.Constants.accountIconLength / 2
        view.clipsToBounds = true
        return view
    }

    func set(viewColor newColor: UIColor?) {
        for arrangedSubview in containerStackView.arrangedSubviews {
            arrangedSubview.backgroundColor = newColor
        }
    }

    func set(layerColor newColor: UIColor?) {
        for arrangedSubview in containerStackView.arrangedSubviews {
            arrangedSubview.layer.backgroundColor = newColor?.cgColor
        }
    }

    func animationWillBegin() {}
    func animationDidEnd() {}
}
