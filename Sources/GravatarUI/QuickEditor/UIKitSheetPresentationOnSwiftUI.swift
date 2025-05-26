import SwiftUI
import UIKit

/// This is the view controller which will present the UIKit sheet from the SwiftUI context.
///
class QuickEditorBottomSheetPresenterViewController: UIViewController {
    let presenter: QuickEditorPresenter

    let completion: (() -> Void)? = nil
    let onUpdate: ((QuickEditorUpdateType) -> Void)?
    let onDismiss: (() -> Void)?

    init(
        email: Email,
        scopeOption: QuickEditorScopeOption,
        configuration: QuickEditorConfiguration,
        token: String?, completion: (() -> Void)? = nil,
        onUpdate: ((QuickEditorUpdateType) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.presenter = QuickEditorPresenter(
            email: email,
            scopeOption: scopeOption,
            configuration: configuration,
            token: token
        )
        self.onUpdate = onUpdate
        self.onDismiss = onDismiss

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

        presenter.present(in: self, animated: true) {
            self.completion?()
        } onUpdate: { update in
            self.onUpdate?(update)
        } onDismiss: {
            self.onDismiss?()
        }
    }
}

/// SwiftUI representable version of `QuickEditorBottomSheetPresenterViewController`
struct QuickEditorBottomSheetPresenterViewControllerRepresentable: UIViewControllerRepresentable {
    let email: Email
    let scopeOption: QuickEditorScopeOption
    let configuration: QuickEditorConfiguration
    let token: String?, completion: (() -> Void)?
    let onUpdate: ((QuickEditorUpdateType) -> Void)?
    let onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> UIViewController {
        QuickEditorBottomSheetPresenterViewController(
            email: email,
            scopeOption: scopeOption,
            configuration: configuration,
            token: token,
            onUpdate: onUpdate,
            onDismiss: onDismiss
        )
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
