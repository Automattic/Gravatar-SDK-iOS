import UIKit
import SwiftUI

/// Configuration which will be applied to the avatar picker screen.
public struct AvatarPickerConfiguration : Sendable{
    let contentLayout: AvatarPickerContentLayoutWithPresentation

    public init(contentLayout: AvatarPickerContentLayoutWithPresentation) {
        self.contentLayout = contentLayout
    }

    static let `default` = AvatarPickerConfiguration(
        contentLayout: .horizontal(presentationStyle: .intrinsicHeight)
    )
}

public final class QuickEditorViewController: UIViewController {
    let email: Email
    let scope: QuickEditorScope

    let avatarPickerConfiguration: AvatarPickerConfiguration

    private lazy var isPresented: Binding<Bool> = Binding {
        return true
    } set: { isPresented in
        guard !isPresented else { return }
        self.dismiss(animated: true)
    }

    private lazy var quickEditor: InnerHeightUIHostingController = .init(rootView: QuickEditor(
        email: email,
        scope: scope,
        isPresented: isPresented,
        customImageEditor: nil as NoCustomEditorBlock?, 
        contentLayoutProvider: avatarPickerConfiguration.contentLayout
    ), onHeightChange: { [weak self] newHeight in
        self?.updateHeight(with: newHeight)
    })

    public init(email: Email, scope: QuickEditorScope, avatarPickerConfiguration: AvatarPickerConfiguration? = nil) {
        self.email = email
        self.scope = scope
        self.avatarPickerConfiguration = avatarPickerConfiguration ?? .default
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder, email: Email, scope: QuickEditorScope, avatarPickerConfiguration: AvatarPickerConfiguration? = nil) {
        self.email = email
        self.scope = scope
        self.avatarPickerConfiguration = avatarPickerConfiguration ?? .default
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func encode(with coder: NSCoder) {
        coder.encodeConditionalObject(email, forKey: "kQEEmial")
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

    func updateHeight(with newHeight: CGFloat) {
        switch avatarPickerConfiguration.contentLayout {
        case .vertical(let presentationStyle):
            verticalLayout(with: presentationStyle)
        case .horizontal:
            setupSheet(with: newHeight)
        }
    }

    func verticalLayout(with layout: VerticalContentPresentationStyle) {
        switch layout {
        case .large:
            setupSheet(detents: [.large()])
        case .expandableMedium(let initial, let prioritizeScrollOverResize):
            if #available(iOS 16.0, *) {
                setupSheet(
                    detents: [.custom { context in context.maximumDetentValue * initial }, .large()],
                    prioritizeScrollOverResize: prioritizeScrollOverResize
                )
            } else {
                setupSheet(
                    detents: [.medium(), .large()],
                    prioritizeScrollOverResize: prioritizeScrollOverResize
                )
            }
        }
    }

    func setupSheet(
        with customHeight: CGFloat? = nil,
        detents: [UISheetPresentationController.Detent] = [],
        prioritizeScrollOverResize: Bool = true)
    {
        if let sheet = sheetPresentationController {
            sheet.animateChanges {
                var finalDetents = [UISheetPresentationController.Detent]()
                if #available(iOS 16.0, *) {
                    if let customHeight {
                        finalDetents.append(.custom { _ in customHeight })
                    }
                    finalDetents.append(contentsOf: detents)
                    sheet.detents = finalDetents
                } else {
                    sheet.detents = detents.isEmpty ? [.large()] : detents
                }
                sheet.prefersScrollingExpandsWhenScrolledToEdge = !prioritizeScrollOverResize
            }
        }
    }
}


/// UIHostingController subclass which reads the InnerHeightPreferenceKey changes
private class InnerHeightUIHostingController: UIHostingController<AnyView> {
    let onHeightChange: (CGFloat) -> Void

    init<V: View>(rootView: V, onHeightChange: @escaping (CGFloat) -> Void) {
        self.onHeightChange = onHeightChange
        weak var weakSelf: InnerHeightUIHostingController?
        super.init(rootView: AnyView(rootView
            .onPreferenceChange(InnerHeightPreferenceKey.self) {
                weakSelf?._innerSwiftUIContentHeight = $0
            }
        ))
        weakSelf = self
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private var _innerSwiftUIContentHeight: CGFloat = 0 {
        didSet { onHeightChange(_innerSwiftUIContentHeight) }
    }
}
