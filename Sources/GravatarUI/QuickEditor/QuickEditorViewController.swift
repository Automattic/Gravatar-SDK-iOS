import SwiftUI
import UIKit

public typealias CustomImageEditorControllerProvider = (UIImage, @escaping @Sendable (UIImage) -> Void) -> CustomImageEditorController

final class QuickEditorViewController<ImageEditor: ImageEditorView>: UIViewController,
    ModalPresentationWithIntrinsicSize,
    UISheetPresentationControllerDelegate
{
    private let email: Email
    private let token: String?
    private let customImageEditorProvider: ImageEditorBlock<ImageEditor>?
    private let updateHandler: ((QuickEditorUpdateType) -> Void)?
    private let onDismiss: (() -> Void)?

    private let unsavedChangesAlertPresentationModel = UnsavedChangesAlertPresentationModel()
    private var sheetHeight: CGFloat = QEModalPresentationConstants.bottomSheetEstimatedHeight
    private var currentPage: QuickEditorPage

    private lazy var isPresented: Binding<Bool> = Binding {
        true
    } set: { [weak self] isPresented in
        Task { @MainActor in
            guard !isPresented else { return }
            self?.dismiss(animated: true)
            self?.onDismiss?()
        }
    }

    var verticalSizeClass: UserInterfaceSizeClass?
    let scopeOption: QuickEditorScopeOption

    private lazy var rootView = QuickEditor(
        email: email,
        scopeOption: scopeOption,
        token: token,
        isPresented: isPresented,
        customImageEditor: customImageEditorProvider,
        updateHandler: updateHandler,
        unsavedChangesAlertPresentationModel: unsavedChangesAlertPresentationModel
    )

    private lazy var quickEditor: InnerHeightUIHostingController = .init(
        rootView: rootView,
        onHeightChange: { [weak self] newHeight in
            guard let self else { return }
            if self.shouldAcceptHeight(newHeight) {
                self.sheetHeight = newHeight
            }
            self.updateDetents()
        },
        onVerticalSizeClassChange: { [weak self] verticalSizeClass in
            guard let self, verticalSizeClass != nil else { return }
            self.verticalSizeClass = verticalSizeClass
            self.updateDetents()
        },
        onPageChange: { [weak self] newValue in
            guard let self else { return }
            self.currentPage = newValue
            self.updateDetents()
        }
    )

    init(
        email: Email,
        scopeOption: QuickEditorScopeOption,
        customImageEditorProvider: ImageEditorBlock<ImageEditor>? = nil,
        token: String? = nil,
        onUpdate: ((QuickEditorUpdateType) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.email = email
        self.scopeOption = scopeOption

        self.token = token
        self.onDismiss = onDismiss
        self.updateHandler = onUpdate
        self.currentPage = scopeOption.initialPage
        self.customImageEditorProvider = customImageEditorProvider
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
            sheet.animateChanges { [weak self] in
                guard let self else { return }
                sheet.detents = QEDetent.detents(
                    for: scopeOption,
                    intrinsicHeight: sheetHeight,
                    verticalSizeClass: verticalSizeClass,
                    currentPage: currentPage
                ).map()
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = !shouldPrioritizeScrollOverResize
            sheet.delegate = self
        }
    }

    func presentationControllerShouldDismiss(_: UIPresentationController) -> Bool {
        if unsavedChangesAlertPresentationModel.hasUnsavedChanges {
            unsavedChangesAlertPresentationModel.presentAlert = true
        }
        return !unsavedChangesAlertPresentationModel.hasUnsavedChanges
    }

    func presentationControllerDidDismiss(_: UIPresentationController) {
        isPresented.wrappedValue = false
    }
}

/// UIHostingController subclass which reads the InnerHeightPreferenceKey changes
private class InnerHeightUIHostingController: UIHostingController<AnyView> {
    let onHeightChange: (CGFloat) -> Void
    let onVerticalSizeClassChange: (UserInterfaceSizeClass?) -> Void
    let onPageChange: (QuickEditorPage) -> Void

    init(
        rootView: some View,
        onHeightChange: @escaping (CGFloat) -> Void,
        onVerticalSizeClassChange: @escaping (UserInterfaceSizeClass?) -> Void,
        onPageChange: @escaping (QuickEditorPage) -> Void
    ) {
        self.onHeightChange = onHeightChange
        self.onVerticalSizeClassChange = onVerticalSizeClassChange
        self.onPageChange = onPageChange
        weak var weakSelf: InnerHeightUIHostingController?
        super.init(rootView: AnyView(
            rootView
                .onPreferenceChange(InnerHeightPreferenceKey.self) { newHeight in
                    Task { @MainActor in
                        weakSelf?._innerSwiftUIContentHeight = newHeight
                    }
                }
                .onPreferenceChange(VerticalSizeClassPreferenceKey.self) { newSizeClass in
                    Task { @MainActor in
                        weakSelf?._innerVerticalSizeClass = newSizeClass
                    }
                }
                .onPreferenceChange(QuikcEditorCurrentPagePreferenceKey.self) { newValue in
                    Task { @MainActor in
                        weakSelf?._innerCurrentPage = newValue
                    }
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

    private var _innerCurrentPage: QuickEditorPage = .avatarPicker {
        didSet { onPageChange(_innerCurrentPage) }
    }
}

/// A struct responsible for presenting the Quick Editor from a UIKit context.
@MainActor
public struct QuickEditorPresenter {
    private typealias CustomImageEditorProvider = ImageEditorBlock<CustomImageEditorControllerRepresentable>?

    let email: Email
    let scopeOption: QuickEditorScopeOption
    let configuration: QuickEditorConfiguration
    let token: String?

    /// Initializes the `QuickEditorPresenter` with the required parameters.
    /// - Parameters:
    ///   - email: User's email.
    ///   - scope: The scope in which the editor is used.
    ///   - configuration: Optional editor configuration. Defaults to `.default`.
    ///   - token: Optional authorization token. If none is provided, an OAuth screen will be presented for the user to authorise this session. See
    /// <doc:GravatarOAuth> for more
    @available(*, deprecated, renamed: "init(email:scopeOption:configuration:token:)", message: "The new scope parameter is of type `QuickEditorScopeOption`")
    public init(
        email: Email,
        scope: QuickEditorScope,
        configuration: QuickEditorConfiguration? = nil,
        token: String? = nil
    ) {
        self.email = email
        if case .avatarPicker(let config) = scope {
            self.scopeOption = .avatarPicker(.init(contentLayout: config.contentLayout))
        } else {
            self.scopeOption = .avatarPicker(.horizontalInstrinsicHeight)
        }
        self.configuration = configuration ?? .default
        self.token = token
    }

    /// Initializes the `QuickEditorPresenter` with the required parameters.
    /// - Parameters:
    ///   - email: User's email.
    ///   - scopeOption: The scope in which the editor is used.
    ///   - configuration: Optional editor configuration. Defaults to `.default`.
    ///   - token: Optional authorization token. If none is provided, an OAuth screen will be presented for the user to authorise this session. See
    /// <doc:GravatarOAuth> for more info.
    public init(
        email: Email,
        scopeOption: QuickEditorScopeOption,
        configuration: QuickEditorConfiguration? = nil,
        token: String? = nil
    ) {
        self.email = email
        self.scopeOption = scopeOption
        self.configuration = configuration ?? .default
        self.token = token
    }

    /// Presents the Quick Editor
    /// - Parameters:
    ///   - parent: The UIViewController from which to present the Quick Editor.
    ///   - animated: Whether the presentation should be animated. Defaults to `true`.
    ///   - completion: An optional closure called after the presentation finishes.
    ///   - onAvatarUpdated: An optional closure triggered when the avatar is updated.
    ///   - onDismiss: An optional closure triggered when the editor is dismissed.
    @MainActor
    @available(*, deprecated, renamed: "init(in:animated:completion:onUpdate:onDismiss:)")
    public func present(
        in parent: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        onAvatarUpdated: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let customImageEditorProvider: CustomImageEditorProvider = if let customProvider = configuration.customImageEditorProvider {
            { image, callback in
                CustomImageEditorControllerRepresentable(
                    controllerProvider: customProvider,
                    inputImage: image,
                    editingDidFinish: callback
                )
            }
        } else {
            nil as ImageEditorBlock<CustomImageEditorControllerRepresentable>?
        }

        let quickEditor = QuickEditorViewController(
            email: email,
            scopeOption: scopeOption,
            customImageEditorProvider: customImageEditorProvider,
            token: token,

            onUpdate: { _ in
                onAvatarUpdated?()
            },
            onDismiss: onDismiss
        )

        quickEditor.overrideUserInterfaceStyle = configuration.interfaceStyle
        parent.present(quickEditor, animated: animated, completion: completion)
    }

    /// Presents the Quick Editor
    /// - Parameters:
    ///   - parent: The UIViewController from which to present the Quick Editor.
    ///   - animated: Whether the presentation should be animated. Defaults to `true`.
    ///   - completion: An optional closure called after the presentation finishes.
    ///   - onUpdate: An optional closure triggered when the user profile info is updated.
    ///   - onDismiss: An optional closure triggered when the editor is dismissed.
    @MainActor
    public func present(
        in parent: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        onUpdate: ((QuickEditorUpdateType) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let customImageEditorProvider: CustomImageEditorProvider = if let customProvider = configuration.customImageEditorProvider {
            { image, callback in
                CustomImageEditorControllerRepresentable(
                    controllerProvider: customProvider,
                    inputImage: image,
                    editingDidFinish: callback
                )
            }
        } else {
            nil as ImageEditorBlock<CustomImageEditorControllerRepresentable>?
        }

        let quickEditor = QuickEditorViewController(
            email: email,
            scopeOption: scopeOption,
            customImageEditorProvider: customImageEditorProvider,
            token: token,
            onUpdate: onUpdate,
            onDismiss: onDismiss
        )

        quickEditor.overrideUserInterfaceStyle = configuration.interfaceStyle
        parent.present(quickEditor, animated: animated, completion: completion)
    }
}

/// A protocol defining a customizable image editor interface used in the Quick Editor flow.
///
/// This `UIViewController` subclass is presented modally after the user selects an image from their photo library and before it is uploaded to Gravatar.
/// It provides an opportunity to:
/// - Enforce a square aspect ratio.
/// - Apply arbitrary, user-defined customizations to the image.
///
/// Conforming types must return the final edited image via the `editingDidFinish` closure.
@MainActor
public protocol CustomImageEditorController: UIViewController {
    /// The input image selected by the user.
    var inputImage: UIImage { get }
    /// A closure that must be called with the final edited image when editing is complete.
    var editingDidFinish: @Sendable (UIImage) -> Void { get }
}

private struct CustomImageEditorControllerRepresentable: UIViewControllerRepresentable, ImageEditorView {
    var inputImage: UIImage
    var editingDidFinish: @Sendable (UIImage) -> Void

    let controllerProvider: CustomImageEditorControllerProvider

    init(
        controllerProvider: @escaping CustomImageEditorControllerProvider,
        inputImage: UIImage,
        editingDidFinish: @escaping @Sendable (UIImage) -> Void
    ) {
        self.controllerProvider = controllerProvider
        self.inputImage = inputImage
        self.editingDidFinish = editingDidFinish
    }

    func makeUIViewController(context: Context) -> UIViewController {
        controllerProvider(inputImage, editingDidFinish)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
