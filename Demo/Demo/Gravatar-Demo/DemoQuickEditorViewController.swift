import UIKit
import SwiftUI
import GravatarUI

final class DemoQuickEditorViewController: UIViewController {
    var savedEmail: String? {
        get {
            UserDefaults.standard.string(forKey: "QEEmailKey")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "QEEmailKey")
        }
    }

    var savedToken: String? {
        get {
            UserDefaults.standard.string(forKey: "QETokenKey")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "QETokenKey")
        }
    }

    private var selectedAboutInfoFields: AboutInfoField  {
        get {
            if let rawValue = UserDefaults.standard.object(forKey: "demoSelectedAboutInfoFields") as? AboutInfoField.RawValue {
                return AboutInfoField(rawValue: rawValue)
            } else {
                return AboutInfoField.all
            }
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "demoSelectedAboutInfoFields")
        }
    }

    lazy var emailField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textContentType = .emailAddress
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.borderStyle = .roundedRect
        field.placeholder = "email"
        field.delegate = self
        field.text = savedEmail
        return field
    }()

    lazy var tokenField: UITextField = {
        let field = UITextField()
        let showButton = UIButton(type: .custom, primaryAction: UIAction { action in
            field.isSecureTextEntry = !field.isSecureTextEntry
            (action.sender as? UIButton)?.isSelected = !field.isSecureTextEntry

        })
        showButton.tintColor = .systemGray
        showButton.setImage(UIImage(systemName: "eye"), for: .normal)
        showButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)

        field.rightView = showButton
        field.rightViewMode = .always

        field.translatesAutoresizingMaskIntoConstraints = false
        field.isSecureTextEntry = true

        field.autocapitalizationType = .none
        field.borderStyle = .roundedRect
        field.placeholder = "Token (optional)"
        field.text = savedToken
        field.delegate = self
        return field
    }()

    var token: String? {
        guard let token = tokenField.text, !token.isEmpty else { return nil }
        savedToken = token
        return token
    }

    var selectedLayout: AvatarPickerLayoutOptions = .horizontal {
        didSet {
            layoutButton.setTitle(selectedLayout.rawValue, for: .normal)
        }
    }

    var selectedInitialPage: InitialPage = .avatarPicker {
        didSet {
            initialPageButton.setTitle("Initial page: \(selectedInitialPage.rawValue)", for: .normal)
        }
    }

    private var selectedScopeOption: QuickEditorScopeOption {
        switch selectedScope {
        case .avatarPicker:
            .avatarPicker(.init(contentLayout: selectedLayout.contentLayout))
        case .aboutEditor:
            .aboutEditor(.init(
                presentationStyle: selectedSheetPresentationStyle,
                fields: selectedAboutInfoFields
            ))
        case .avatarAndAboutEditor:
            .avatarPickerAndAboutInfoEditor(
                .init(
                    contentLayout: selectedLayout.contentLayout,
                    fields: selectedAboutInfoFields,
                    initialPage: selectedInitialPage.map()
                )
            )
        }
    }

    private var selectedScope: QEScope = .avatarPicker {
        didSet {
            scopeButton.setTitle("Scope: \(selectedScope.rawValue)", for: .normal)
            showOptionsPerScope()
        }
    }

    func showOptionsPerScope() {
        (avatarPickerOptionsViews + aboutEditorOptionsStackView + avatarAndAboutEditorOptionsStackView).forEach {
            $0.isHiddenForAnimation = true
        }

        switch selectedScope {
        case .avatarPicker:
            avatarPickerOptionsViews.forEach { $0.isHiddenForAnimation = false }
        case .aboutEditor:
            aboutEditorOptionsStackView.forEach { $0.isHiddenForAnimation = false }
        case .avatarAndAboutEditor:
            avatarAndAboutEditorOptionsStackView.forEach {
                $0.isHiddenForAnimation = false
            }
        }
    }

    private var selectedSheetPresentationStyle: SheetPresentationStyle {
        switch selectedSheetPresentationStyleRepresentation {
        case .expandableMedium:
            .expandableMedium()
        case .expandableMediumPrioritizeScrolling:
            .expandableMedium(prioritizeScrollOverResize: true)
        case .large:
            .large()
        case .intrinsicHeight:
            .intrinsicHeight()
        case .automatic:
            .automatic()
        case .automaticPrioritizeScrolling:
            .automatic(prioritizeScrollOverResize: true)
        }
    }

    private var selectedSheetPresentationStyleRepresentation: SheetPresentationStyleRepresentation = .expandableMedium {
        didSet {
            aboutPresentationStyleButton.setTitle(
                "Sheet Presentation Style: \(selectedSheetPresentationStyleRepresentation.rawValue)",
                for: .normal
            )
        }
    }

    lazy var profileSummaryView: ProfileSummaryView = {
        let view = ProfileSummaryView(frame: .zero, paletteType: .system, profileButtonStyle: .edit)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarActivityIndicatorType = .activity
        return view
    }()

    private lazy var prefersEphemeralSessionToggle: SwitchWithLabel = {
        let view = SwitchWithLabel(labelText: "Prefers ephemeral browser session")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.switchView.addTarget(self, action: #selector(togglePrefersEphemeralSession), for: .valueChanged)
        return view
    }()

    lazy var layoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Layout: \(selectedLayout.rawValue)", for: .normal)
        button.addTarget(self, action: #selector(presentLayoutOptions), for: .touchUpInside)
        return button
    }()

    lazy var initialPageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("InititalPage: \(selectedInitialPage.rawValue)", for: .normal)
        button.addTarget(self, action: #selector(presentInitialPageOptions), for: .touchUpInside)
        return button
    }()

    lazy var scopeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Scope: \(selectedScope.rawValue)", for: .normal)
        button.addTarget(self, action: #selector(presentScopeOptions), for: .touchUpInside)
        return button
    }()

    lazy var aboutPresentationStyleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sheet Presentation Style: \(selectedSheetPresentationStyleRepresentation.rawValue)", for: .normal)
        button.addTarget(self, action: #selector(presentVerticalPresentationStyleOptions), for: .touchUpInside)
        return button
    }()

    lazy var aboutFieldsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Select input fields", for: .normal)
        button.addTarget(self, action: #selector(aboutFieldsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func presentLayoutOptions(from button: UIButton) {
        let sheet = UIAlertController(title: "Layout Options", message: nil, preferredStyle: .actionSheet)
        AvatarPickerLayoutOptions.allCases.forEach { layout in
            sheet.addAction(.init(title: layout.rawValue, style: .default) { _ in
                self.selectedLayout = layout
            })
        }
        sheet.popoverPresentationController?.sourceView = button
        present(sheet, animated: true)
    }

    @objc func presentInitialPageOptions(from button: UIButton) {
        let sheet = UIAlertController(title: "Initial Page", message: nil, preferredStyle: .actionSheet)
        InitialPage.allCases.forEach { page in
            sheet.addAction(.init(title: page.rawValue, style: .default) { _ in
                self.selectedInitialPage = page
            })
        }
        sheet.popoverPresentationController?.sourceView = button
        present(sheet, animated: true)
    }

    @objc func presentScopeOptions(from button: UIButton) {
        let sheet = UIAlertController(title: "Scope Options", message: nil, preferredStyle: .actionSheet)
        QEScope.allCases.forEach { scope in
            sheet.addAction(.init(title: scope.rawValue, style: .default) { _ in
                self.selectedScope = scope
            })
        }
        sheet.popoverPresentationController?.sourceView = button
        present(sheet, animated: true)
    }

    @objc func presentVerticalPresentationStyleOptions(from button: UIButton) {
        let sheet = UIAlertController(title: "Vertical Presentation Styles", message: nil, preferredStyle: .actionSheet)
        SheetPresentationStyleRepresentation.allCases.forEach { style in
            sheet.addAction(.init(title: style.rawValue, style: .default) { _ in
                self.selectedSheetPresentationStyleRepresentation = style
            })
        }
        sheet.popoverPresentationController?.sourceView = button
        present(sheet, animated: true)
    }

    @objc func aboutFieldsButtonTapped() {
        let aboutChecklistHostingController = UIHostingController(
            rootView: AboutInfoChecklistView(
                selectedFields: Binding(
                    get: {
                        self.selectedAboutInfoFields
                    },
                    set: { fields in
                        self.selectedAboutInfoFields = fields
                    }
                )
            )
        )
        aboutChecklistHostingController.sheetPresentationController?.detents = [.large()]
        present(aboutChecklistHostingController, animated: true)
    }

    lazy var colorSchemeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Prefered color scheme:"
        return label
    }()

    lazy var schemeToggle: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            UIAction.init(title: "System") { _ in self.customColorScheme = .unspecified },
            UIAction.init(title: "Light") { _ in self.customColorScheme = .light },
            UIAction.init(title: "Dark") { _ in self.customColorScheme = .dark },
        ])
        control.selectedSegmentIndex = 0
        return control
    }()

    lazy var imageEditorToggle: UISegmentedControl = {
        let control = UISegmentedControl(items: [
            UIAction.init(title: "Default Image Editor") { _ in self.useCustomImageEditor = false },
            UIAction.init(title: "Custom Image Editor") { _ in self.useCustomImageEditor = true },
        ])
        control.selectedSegmentIndex = 0
        return control
    }()

    var customColorScheme: UIUserInterfaceStyle = .unspecified
    var useCustomImageEditor = false

    lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: .normal)
        button.addAction(UIAction { [weak self] _ in self?.logout() }, for: .touchUpInside)
        updateLogoutButton(button)
        return button
    }()

    func updateLogoutButton(_ button: UIButton? = nil) {
        guard let savedEmail else { return }
        let button = button ?? logoutButton
        if #available(iOS 17, *) {
            UIView.animate {
                button.isHidden = !OAuthSession.shared.hasSession(with: Email(savedEmail))
                button.alpha = button.isHidden ? 0 : 1
            }
        } else {
            button.isHidden = !OAuthSession.shared.hasSession(with: Email(savedEmail))
            button.alpha = button.isHidden ? 0 : 1
        }
    }

    func logout() {
        guard let savedEmail else { return }
        OAuthSession.shared.deleteSession(with: Email(savedEmail))
        updateLogoutButton()
    }

    lazy var showButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Quick Editor", for: .normal)
        button.addAction(UIAction { [weak self] _ in self?.presentQuickEditor() }, for: .touchUpInside)
        button.isEnabled = savedEmail != nil
        return button
    }()

    lazy var avatarPickerOptionsViews: [UIView] = [
        imageEditorToggle,
        layoutButton,
    ]

    lazy var aboutEditorOptionsStackView: [UIView] = [
        aboutPresentationStyleButton,
        aboutFieldsButton
    ]

    lazy var avatarAndAboutEditorOptionsStackView: [UIView] = [
        imageEditorToggle,
        layoutButton,
        aboutFieldsButton,
        initialPageButton
    ]

    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailField,
            tokenField,
            profileSummaryView,
            colorSchemeLabel,
            schemeToggle,
            prefersEphemeralSessionToggle,
            scopeButton,
            imageEditorToggle,
            layoutButton,
            aboutPresentationStyleButton,
            aboutFieldsButton,
            initialPageButton,
            logoutButton,
            showButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        if let savedEmail {
            fetchProfile(with: savedEmail)
        }
        showOptionsPerScope()
    }

    func presentQuickEditor() {
        guard let email = emailField.text else { return }
        savedEmail = email
        let imageEditorProvider: CustomImageEditorControllerProvider? = {
            if self.useCustomImageEditor {
                return { image, callback in
                    return MyCustomImageEditorController(inputImage: image, editingDidFinish: callback)
                }
            } else {
                return nil
            }
        }()

        let presenter = QuickEditorPresenter(
            email: Email(email),
            scopeOption: selectedScopeOption,
            configuration: .init(
                interfaceStyle: customColorScheme,
                customImageEditorProvider: imageEditorProvider
            ),
            token: token
        )
        presenter.present(
            in: self,
            onUpdate: { [weak self] updateType in
                switch updateType {
                case is QuickEditorUpdate.Avatar:
                    self?.profileSummaryView.loadAvatar(with: .email(email), rating: .x, options: [.forceRefresh])
                case let update as QuickEditorUpdate.AboutInfo:
                    self?.profileSummaryView.update(with: update.profile)
                default:
                    break
                }
            },
            onDismiss: { [weak self] in
                self?.updateLogoutButton()
            }
        )
    }
    
    @objc func togglePrefersEphemeralSession() {
        Task {
            await OAuthSession.shared.setPrefersEphemeralWebBrowserSession(prefersEphemeralSessionToggle.isOn)
        }
    }
}

extension DemoQuickEditorViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField == emailField else { return }
        if let emailText = textField.text, Email(emailText).isValid {
            fetchProfile(with: emailText)
            showButton.isEnabled = true
        } else {
            showButton.isEnabled = false
        }
    }

    func fetchProfile(with email: String) {
        Task {
            let email = Email(email)
            let service = ProfileService()
            profileSummaryView.loadAvatar(with: .email(email))
            let profile = try? await service.fetch(with: .email(email))
            profileSummaryView.update(with: profile)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if textField == tokenField {
            savedToken = textField.text
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Email {
    // This validation is not perfect, but it's intended for demo purposes only.
    public var isValid: Bool {
        let string = rawValue
        guard string.count <= 254 else {
            return false
        }
        let atIndex = string.lastIndex(of: "@") ?? string.endIndex
        let dotIndex = string.lastIndex(of: ".") ?? string.endIndex
        return (atIndex != string.startIndex)
            && (dotIndex > atIndex)
            && (string[atIndex...].count > 4)
            && (string[dotIndex...].count > 2)
    }
}

class MyCustomImageEditorController: UIViewController, CustomImageEditorController {
    var inputImage: UIImage
    var editingDidFinish: @Sendable (UIImage) -> Void

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is a dummy image editor for test purposes only. It doesn't do anything other than passing the image back as it is when the button is tapped."
        label.numberOfLines = 0
        return label
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: inputImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let button: UIButton = {
        let button = UIButton(configuration: .borderedTinted())
        button.configuration?.title = "Done"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    required init(
        nibName nibNameOrNil: String? = nil,
        bundle nibBundleOrNil: Bundle? = nil,
        inputImage: UIImage,
        editingDidFinish: @Sendable @escaping (UIImage) -> Void
    ) {
        self.inputImage = inputImage
        self.editingDidFinish = editingDidFinish
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
            rootStackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
        ])

        rootStackView.addArrangedSubview(label)
        rootStackView.addArrangedSubview(imageView)
        rootStackView.addArrangedSubview(button)

        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            editingDidFinish(inputImage)
        }, for: .touchUpInside)
    }
}

enum QEScope: String, CaseIterable, Hashable {
    case avatarPicker = "Avatar Picker"
    case aboutEditor = "About Editor"
    case avatarAndAboutEditor = "Avatar & About Editor"
}

enum SheetPresentationStyleRepresentation: String, CaseIterable, Hashable {
    case large = "Large"
    case expandableMedium = "Expandable Medium"
    case expandableMediumPrioritizeScrolling = "Expandable Medium - Prioritize scrolling"
    case intrinsicHeight = "Intrinsic Height"
    case automatic = "Automatic"
    case automaticPrioritizeScrolling = "Automatic - Prioritize scrolling"
}

private extension UIView {
    var isHiddenForAnimation: Bool {
        get {
            return isHidden && alpha == 0
        }
        set {
            self.alpha = newValue ? 0 : 1
            self.isHidden = newValue
        }
    }
}
