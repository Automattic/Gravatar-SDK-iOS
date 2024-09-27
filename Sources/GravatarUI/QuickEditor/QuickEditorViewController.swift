import UIKit
import SwiftUI

public final class QuickEditorViewController: UIViewController {
    let email: Email
    let scope: QuickEditorScope

    lazy var isPresented: Binding<Bool> = Binding {
        return true
    } set: { isPresented in
        guard !isPresented else { return }
        self.dismiss(animated: true)
    }

    lazy var quickEditor: UIHostingController = .init(rootView: QuickEditor(
        email: email,
        scope: scope,
        isPresented: isPresented,
        customImageEditor: nil as NoCustomEditorBlock?)
    )

    public init(email: Email, scope: QuickEditorScope) {
        self.email = email
        self.scope = scope
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
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
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController != nil {
            assertionFailure("This View Controller should be presented modally, without wrapping it in a Navigation Controller.")
        }
    }
}
