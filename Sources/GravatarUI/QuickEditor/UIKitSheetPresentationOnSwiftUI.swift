import SwiftUI
import UIKit

/// This is the view controller which will present the UIKit sheet from the SwiftUI context.
///
class QuickEditorBottomSheetPresenterViewController<ImageEditor: ImageEditorView>: UIViewController {
    let email: Email
    let scopeOption: QuickEditorScopeOption

    let token: String?
    let customImageEditor: ImageEditorBlock<ImageEditor>?

    let completion: (() -> Void)? = nil
    let onUpdate: ((QuickEditorUpdateType) -> Void)?
    let onDismiss: (() -> Void)?

    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        didSet {
            presentedViewController?.overrideUserInterfaceStyle = overrideUserInterfaceStyle
        }
    }

    init(
        email: Email,
        scopeOption: QuickEditorScopeOption,
        token: String?,
        customImageEditorProvider: ImageEditorBlock<ImageEditor>? = nil,
        completion: (() -> Void)? = nil,
        onUpdate: ((QuickEditorUpdateType) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.email = email
        self.scopeOption = scopeOption
        self.token = token
        self.onUpdate = onUpdate
        self.onDismiss = onDismiss
        self.customImageEditor = customImageEditorProvider

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let quickEditor = QuickEditorViewController(
            email: email,
            scopeOption: scopeOption,
            customImageEditorProvider: customImageEditor,
            token: token,
            onUpdate: onUpdate,
            onDismiss: onDismiss
        )

        quickEditor.overrideUserInterfaceStyle = overrideUserInterfaceStyle

        present(quickEditor, animated: true)
    }
}

/// SwiftUI representable version of `QuickEditorBottomSheetPresenterViewController`
struct QuickEditorBottomSheetPresenterViewControllerRepresentable<ImageEditor: ImageEditorView>: UIViewControllerRepresentable {
    let email: Email
    let scopeOption: QuickEditorScopeOption
    let token: String?
    let customImageEditor: ImageEditorBlock<ImageEditor>?
    let onUpdate: ((QuickEditorUpdateType) -> Void)?
    let onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> UIViewController {
        QuickEditorBottomSheetPresenterViewController(
            email: email,
            scopeOption: scopeOption,
            token: token,
            customImageEditorProvider: customImageEditor,
            onUpdate: onUpdate,
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.overrideUserInterfaceStyle = UIUserInterfaceStyle(context.environment.colorScheme)
    }
}
