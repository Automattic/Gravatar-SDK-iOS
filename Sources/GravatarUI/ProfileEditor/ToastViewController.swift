import UIKit

private typealias Attribute = AttributeScopes.UIKitAttributes

class ToastViewController: UIViewController {
    private enum Constants {
        static let font = UIFont.preferredFont(forTextStyle: .caption1)
        static var fontColor: UIColor { .label }
        static var backgroudnColor: UIColor { .secondarySystemBackground }
    }

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.font
        label.textColor = Constants.fontColor
        label.numberOfLines = 0
        return label
    }()

    let button: UIButton = {
        var container = AttributeContainer()
        container[Attribute.ForegroundColorAttribute.self] = Constants.fontColor
        container[Attribute.UnderlineStyleAttribute.self] = .single
        container[Attribute.UnderlineColorAttribute.self] = Constants.fontColor
        container[Attribute.FontAttribute.self] = Constants.font

        var config = UIButton.Configuration.borderless()
        // TODO: Localize strings
        config.attributedTitle = AttributedString("Got it", attributes: container)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        return stack
    }()

    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground

        // Drop shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8.0
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.masksToBounds = false
        return view
    }()

    init(title: String) {
        super.init(nibName: nil, bundle: nil)

        // Make contrasting colors using the opposite interface style.
        view.overrideUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle == .light ? .dark : .light

        transitioningDelegate = self
        modalPresentationStyle = .custom

        label.text = title

        let buttonAction = UIAction { [weak self] _ in self?.dismissButtonPressed() }
        button.addAction(buttonAction, for: .touchUpInside)

        containerView.addSubview(rootStackView)
        view.addSubview(containerView)
        makeLayout()

        let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.layoutMargins = insets
        rootStackView.isLayoutMarginsRelativeArrangement = true
        rootStackView.layoutMargins = insets
    }

    private func makeLayout() {
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }

    func dismissButtonPressed() {
        dismiss(animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToastViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ToastPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class PresentationController: UIPresentationController {
    private var calculatedFrameOfPresentedViewInContainerView = CGRect.zero
    private var shouldSetFrameWhenAccessingPresentedView = false

    override var presentationStyle: UIModalPresentationStyle {
        return .overCurrentContext
    }

    override var presentedView: UIView? {
        if shouldSetFrameWhenAccessingPresentedView {
            super.presentedView?.frame = calculatedFrameOfPresentedViewInContainerView
        }

        return super.presentedView
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        shouldSetFrameWhenAccessingPresentedView = completed
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        shouldSetFrameWhenAccessingPresentedView = false

        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate { context in
                context.containerView.alpha = 0
            }
        }
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        calculatedFrameOfPresentedViewInContainerView = frameOfPresentedViewInContainerView
    }
}

class ToastPresentationController: PresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard 
            let containerView = containerView,
            let presentedView = presentedView
        else { return .zero }

        let inset: CGFloat = 0

        // Make sure to account for the safe area insets
        let safeAreaFrame = containerView.bounds.inset(by: containerView.safeAreaInsets)

        let targetWidth = safeAreaFrame.width - 2 * inset
        let fittingSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )
        let targetHeight = presentedView.systemLayoutSizeFitting(
            fittingSize, 
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        ).height

        var frame = safeAreaFrame
        frame.origin.x += inset
        frame.origin.y += frame.size.height - targetHeight - inset
        frame.size.width = targetWidth
        frame.size.height = targetHeight
        return frame
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        containerView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 12
    }
}
