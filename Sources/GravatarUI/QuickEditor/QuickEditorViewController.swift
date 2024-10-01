import SwiftUI
import UIKit

/// Configuration which will be applied to the avatar picker screen.
public struct AvatarPickerConfiguration: Sendable {
    let contentLayout: AvatarPickerContentLayoutWithPresentation

    public init(contentLayout: AvatarPickerContentLayoutWithPresentation) {
        self.contentLayout = contentLayout
    }

    static let `default` = AvatarPickerConfiguration(
        contentLayout: .horizontal(presentationStyle: .intrinsicHeight)
    )
}

final class QuickEditorViewController: UIViewController, ModalPresentationWithIntrinsicSize {
    let email: Email
    let scope: QuickEditorScope
    let token: String?
    let avatarPickerConfiguration: AvatarPickerConfiguration

    var onDismiss: (() -> Void)? = nil

    private lazy var isPresented: Binding<Bool> = Binding {
        true
    } set: { isPresented in
        Task { @MainActor in
            guard !isPresented else { return }
            self.dismiss(animated: true)
            self.onDismiss?()
        }
    }

    var verticalSizeClass: UserInterfaceSizeClass?
    var sheetHeight: CGFloat = QEModalPresentationConstants.bottomSheetEstimatedHeight
    var contentLayoutWithPresentation: AvatarPickerContentLayoutWithPresentation {
        avatarPickerConfiguration.contentLayout
    }

    private lazy var quickEditor: InnerHeightUIHostingController = .init(rootView: QuickEditor(
        email: email,
        scope: scope,
        token: token,
        isPresented: isPresented,
        customImageEditor: nil as NoCustomEditorBlock?,
        contentLayoutProvider: avatarPickerConfiguration.contentLayout
    ), onHeightChange: { [weak self] newHeight in
        guard let self else { return }
        if self.shouldAcceptHeight(newHeight) {
            self.sheetHeight = newHeight
        }
        self.updateDetents()
    }, onVerticalSizeClassChange: { [weak self] verticalSizeClass in
        guard let self, verticalSizeClass != nil else { return }
        self.verticalSizeClass = verticalSizeClass
        self.updateDetents()
    })

    init(
        email: Email,
        scope: QuickEditorScope,
        avatarPickerConfiguration: AvatarPickerConfiguration? = nil,
        token: String? = nil,
        onDismiss: (() -> Void)? = nil)
    {
        self.email = email
        self.scope = scope
        self.avatarPickerConfiguration = avatarPickerConfiguration ?? .default
        self.token = token
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        quickEditor.willMove(toParent: self)
        addChild(quickEditor)
        view.addSubview(quickEditor.view)
        quickEditor.didMove(toParent: self)
        quickEditor.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quickEditor.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            quickEditor.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            quickEditor.view.topAnchor.constraint(equalTo: view.topAnchor),
            quickEditor.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        updateDetents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController != nil {
            assertionFailure("This View Controller should be presented modally, without wrapping it in a Navigation Controller.")
        }
    }

    func updateDetents() {
        if let sheet = sheetPresentationController {
            sheet.animateChanges {
                sheet.detents = QEDetent.detents(
                    for: avatarPickerConfiguration.contentLayout,
                    intrinsicHeight: sheetHeight,
                    verticalSizeClass: verticalSizeClass
                ).map()
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = !avatarPickerConfiguration.contentLayout.prioritizeScrollOverResize
        }
    }
}

/// UIHostingController subclass which reads the InnerHeightPreferenceKey changes
private class InnerHeightUIHostingController: UIHostingController<AnyView> {
    let onHeightChange: (CGFloat) -> Void
    let onVerticalSizeClassChange: (UserInterfaceSizeClass?) -> Void

    init(rootView: some View, onHeightChange: @escaping (CGFloat) -> Void, onVerticalSizeClassChange: @escaping (UserInterfaceSizeClass?) -> Void) {
        self.onHeightChange = onHeightChange
        self.onVerticalSizeClassChange = onVerticalSizeClassChange
        weak var weakSelf: InnerHeightUIHostingController?
        super.init(rootView: AnyView(
            rootView
                .onPreferenceChange(InnerHeightPreferenceKey.self) {
                    weakSelf?._innerSwiftUIContentHeight = $0
                }
                .onPreferenceChange(VerticalSizeClassPreferenceKey.self) { newSizeClass in
                    weakSelf?._innerVerticalSizeClass = newSizeClass
                }
        ))
        weakSelf = self
    }

    @available(*, unavailable)
    @objc
    dynamic required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private var _innerSwiftUIContentHeight: CGFloat = 0 {
        didSet { onHeightChange(_innerSwiftUIContentHeight) }
    }

    private var _innerVerticalSizeClass: UserInterfaceSizeClass? = nil {
        didSet { onVerticalSizeClassChange(_innerVerticalSizeClass) }
    }
}

public struct QuickEditorPresenter {
    let email: Email
    let scope: QuickEditorScope
    let avatarPickerConfiguration: AvatarPickerConfiguration
    let token: String?

    public init(
        email: Email,
        scope: QuickEditorScope,
        avatarPickerConfiguration: AvatarPickerConfiguration? = nil,
        token: String? = nil
    ) {
        self.email = email
        self.scope = scope
        self.avatarPickerConfiguration = avatarPickerConfiguration ?? .default
        self.token = token
    }

    @MainActor
    public func present(
        in parent: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) {
        let quickEditor = QuickEditorViewController(
            email: email,
            scope: scope,
            avatarPickerConfiguration: avatarPickerConfiguration,
            token: token,
            onDismiss: onDismiss
        )
        configure?(quickEditor)
        quickEditor.onDismiss = onDismiss
        parent.present(quickEditor, animated: animated, completion: completion)
    }
}
