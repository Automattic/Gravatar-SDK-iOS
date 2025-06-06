import UIKit
import SwiftUI
import GravatarUI

final class DemoQuickEditorViewController: BaseFormViewController {
    @StoredValue(keyName: "QEEmailKey", defaultValue: "")
    var savedEmail: String

    @StoredValue(keyName: "QETokenKey", defaultValue: "")
    var savedToken: String

    @StoredValue(keyName: "demoSelectedAboutInfoFields", defaultValue: AboutInfoField.all)
    private var selectedAboutInfoFields: AboutInfoField

    lazy var emailField = TextFormField(
        placeholder: "Enter Gravatar Email",
        text: savedEmail,
        keyboardType: .emailAddress,
        delegate: self
    )

    // Add "eye" for showing token
    lazy var tokenField = TextFormField(
        placeholder: "Auth token (optional)",
        text: savedToken,
        isSecure: true,
        delegate: self
    )

    var profileConfig = ProfileViewConfiguration.summary()
    lazy var profileSymmaryViewField = ContentField(contentConfig: profileConfig)

    private lazy var prefersEphemeralSessionToggle = SwitchField(
        title: "Prefers ephemeral browser session",
        action: togglePrefersEphemeralSession
    )

    lazy var layoutButton = ButtonLabelField(
        title: "Layout",
        subtitle: selectedLayout.rawValue,
        buttonTitle: "Select",
        menuActions: AvatarPickerLayoutOptions.allCases.compactMap { [weak self] layout in
            UIAction(title: layout.rawValue) { _ in
                self?.selectedLayout = layout
            }
        },
        selectedMenuActionTitle: selectedLayout.rawValue
    )

    lazy var initialPageButton = ButtonLabelField(
        title: "Initial Page",
        subtitle: selectedInitialPage.rawValue,
        buttonTitle: "Select",
        menuActions: InitialPage.allCases.compactMap { [weak self] page in
            UIAction(title: page.rawValue) { _ in
                self?.selectedInitialPage = page
            }
        },
        selectedMenuActionTitle: selectedInitialPage.rawValue
    )

    lazy var colorSchemeLabel = LabelField(title: "Prefered color scheme:")

    lazy var schemeToggle = SegmentedControlField(segments: ["System", "Light", "Dark"]) { title, index in
        self.customColorScheme = [UIUserInterfaceStyle.unspecified, .light, .dark][index]
    }

    lazy var imageEditorToggle = SwitchField(title: "Custom image editor") { [weak self] value in
        self?.useCustomImageEditor = value
    }

    lazy var scopeButton = ButtonLabelField(
        title: "Scope",
        subtitle: selectedScope.rawValue,
        buttonTitle: "Select",
        menuActions: QEScope.allCases.compactMap { [weak self] scope in
            UIAction(title: scope.rawValue) { _ in
                self?.selectedScope = scope
            }
        },
        selectedMenuActionTitle: selectedScope.rawValue
    )

    lazy var scopeOptionsLabel = LabelField(title: "Scope options:", style: .headline)

    lazy var aboutPresentationStyleButton = ButtonLabelField(
        title: "Sheet Presentation Style",
        subtitle: selectedSheetPresentationStyleRepresentation.rawValue,
        buttonTitle: "Select",
        menuActions: SheetPresentationStyleRepresentation.allCases.compactMap { [weak self] style in
            UIAction(title: style.rawValue) { _ in
                self?.selectedSheetPresentationStyleRepresentation = style
            }
        },
        selectedMenuActionTitle: selectedSheetPresentationStyleRepresentation.rawValue
    )

    lazy var aboutFieldsButton = ButtonLabelField(
        title: "Input fields",
        buttonTitle: "Select",
        action: { [weak self] action in
            self?.aboutFieldsButtonTapped()
        }
    )

    lazy var logoutButton = ButtonField(title: "Logout") { [weak self] action in
        self?.logout()
    }

    lazy var showButton = ButtonField(title: "Show Quick Editor") { [weak self] _ in
        self?.presentQuickEditor()
    }

    var token: String? {
        let token = tokenField.text
        guard !token.isEmpty else { return nil }
        savedToken = token
        return token
    }

    @StoredValue(keyName: "QEAvatarPickerLayoutOptions", defaultValue: .horizontal)
    var selectedLayout: AvatarPickerLayoutOptions {
        didSet {
            layoutButton.subtitle = selectedLayout.rawValue
            layoutButton.selectedMenuActionTitle = selectedLayout.rawValue
            update(layoutButton)
        }
    }

    @StoredValue(keyName: "QEInitialPage", defaultValue: .avatarPicker)
    var selectedInitialPage: InitialPage {
        didSet {
            initialPageButton.subtitle = selectedInitialPage.rawValue
            initialPageButton.selectedMenuActionTitle = selectedInitialPage.rawValue
            update(initialPageButton)
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

    @StoredValue(keyName: "QEScopeValue", defaultValue: .avatarPicker)
    private var selectedScope: QEScope {
        didSet {
            scopeButton.subtitle = selectedScope.rawValue
            scopeButton.selectedMenuActionTitle = selectedScope.rawValue
            update(scopeButton, animated: true)
            showOptionsPerScope()
        }
    }

    func showOptionsPerScope() {
        remove(
            fields: avatarPickerOptionsViews + aboutEditorOptionsStackView + avatarAndAboutEditorOptionsStackView
        )

        switch selectedScope {
        case .avatarPicker:
            add(fields: avatarPickerOptionsViews, after: scopeOptionsLabel)
        case .aboutEditor:
            add(fields: aboutEditorOptionsStackView, after: scopeOptionsLabel)
        case .avatarAndAboutEditor:
            add(fields: avatarAndAboutEditorOptionsStackView, after: scopeOptionsLabel)
        }
        commitUpdates()
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

    @StoredValue(keyName: "QESheetPresentationStyle", defaultValue: .expandableMedium)
    private var selectedSheetPresentationStyleRepresentation: SheetPresentationStyleRepresentation {
        didSet {
            aboutPresentationStyleButton.subtitle = selectedSheetPresentationStyleRepresentation.rawValue
            aboutPresentationStyleButton.selectedMenuActionTitle = selectedSheetPresentationStyleRepresentation.rawValue
            update(aboutPresentationStyleButton)
        }
    }

    func presentMenu(on button: UIButton, actions: [UIAction]) {
        button.menu = UIMenu(title: "",children: actions)
        button.showsMenuAsPrimaryAction = true
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

    var customColorScheme: UIUserInterfaceStyle = .unspecified
    var useCustomImageEditor = false

    func updateLogoutButton() {
        if OAuthSession.shared.hasSession(with: Email(savedEmail)) {
            add(fields: [logoutButton])
        } else {
            remove(fields: [logoutButton])
        }
        commitUpdates()
    }

    func logout() {
        OAuthSession.shared.deleteSession(with: Email(savedEmail))
        updateLogoutButton()
    }

    lazy var avatarPickerOptionsViews: [FormField] = [
        imageEditorToggle,
        layoutButton,
    ]

    lazy var aboutEditorOptionsStackView: [FormField] = [
        aboutPresentationStyleButton,
        aboutFieldsButton
    ]

    lazy var avatarAndAboutEditorOptionsStackView: [FormField] = [
        imageEditorToggle,
        layoutButton,
        aboutFieldsButton,
        initialPageButton
    ]

    override var form: [FormField] {
        [
            emailField,
            tokenField,
            profileSymmaryViewField,
            colorSchemeLabel,
            schemeToggle,
            prefersEphemeralSessionToggle,
            scopeButton,
            scopeOptionsLabel,
            logoutButton,
            showButton
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground

        if !savedEmail.isEmpty {
            fetchProfile()
        }
        showOptionsPerScope()
        updateLogoutButton()
    }

    func presentQuickEditor() {
        let email = savedEmail
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
                    self?.updateAvatar(with: email)
                case let update as QuickEditorUpdate.AboutInfo:
                    self?.updateProfileField(model: update.profile)
                default:
                    break
                }
            },
            onDismiss: { [weak self] in
                self?.updateLogoutButton()
            }
        )
    }

    func updateAvatar(with email: String) {
        profileConfig.avatarIdentifier = .email(email)
        profileConfig.avatarConfiguration.settingOptions = [.forceRefresh, .removeCurrentImageWhileLoading]
        updateProfileField(config: profileConfig)
    }

    func updateProfile() async throws {
        let service = ProfileService()
        profileConfig = newProfileConfig()
        profileConfig.isLoading = true
        updateProfileField(config: profileConfig)

        let profile = try await service.fetch(with: .email(savedEmail))
        updateProfileField(model: profile)
    }

    func updateProfileField(model: ProfileModel) {
        profileConfig = newProfileConfig(with: model)
        profileConfig.avatarIdentifier = .email(savedEmail)
        updateProfileField(config: profileConfig)
    }

    func updateProfileField(config: ProfileViewConfiguration) {
        profileConfig = config
        profileSymmaryViewField.contentConfig = profileConfig
        update(profileSymmaryViewField)
    }

    func newProfileConfig(with model: ProfileModel? = nil) -> ProfileViewConfiguration {
        var profileConfig = ProfileViewConfiguration.summary(model: model)
        profileConfig.avatarConfiguration.settingOptions = [.removeCurrentImageWhileLoading]
        profileConfig.avatarConfiguration.defaultAvatarOption = .status404
        return profileConfig
    }

    func togglePrefersEphemeralSession(to value: Bool) {
        Task {
            await OAuthSession.shared.setPrefersEphemeralWebBrowserSession(value)
        }
    }
}

extension DemoQuickEditorViewController: TextFormFieldDelegate {
    func textFormDidChangeSelection(_ textForm: TextFormField) {
        guard
            textForm === emailField,
            profileConfig.avatarIdentifier?.id != Email(textForm.text).id
        else { return }

        let emailText = textForm.text

        if Email(emailText).isValid {
            savedEmail = emailText
            fetchProfile()
            showButton.isEnabled = true
            updateLogoutButton()
        } else {
            updateProfileField(config: ProfileViewConfiguration.summary())
            showButton.isEnabled = false
        }
    }

    func textFormShouldReturn(_ textForm: TextFormField) -> Bool {
        return true
    }

    func textFormDidEndEditing(_ textForm: TextFormField) {
        if textForm === tokenField {
            savedToken = textForm.text
        }
        if textForm === emailField {
            savedEmail = textForm.text
        }
    }

    func fetchProfile() {
        Task {
            try? await updateProfile()
        }
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
