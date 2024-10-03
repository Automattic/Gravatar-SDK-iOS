import UIKit
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

    var selectedLayout: QELayoutOptions = .horizontal {
        didSet {
            layoutButton.setTitle(selectedLayout.rawValue, for: .normal)
        }
    }

    lazy var profileSummaryView: ProfileSummaryView = {
        let view = ProfileSummaryView(frame: .zero, paletteType: .system, profileButtonStyle: .edit)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.avatarActivityIndicatorType = .activity
//        view.delegate = self
        return view
    }()

    lazy var layoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Layout: \(selectedLayout.rawValue)", for: .normal)
        button.addTarget(self, action: #selector(presentLayoutOptions), for: .touchUpInside)
        return button
    }()

    @objc func presentLayoutOptions() {
        let sheet = UIAlertController(title: "Layout Options", message: nil, preferredStyle: .actionSheet)
        QELayoutOptions.allCases.forEach { layout in
            sheet.addAction(.init(title: layout.rawValue, style: .default) { _ in
                self.selectedLayout = layout
            })
        }
        present(sheet, animated: true)
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

    var customColorScheme: UIUserInterfaceStyle = .unspecified

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
        let session = OAuthSession()
        let button = button ?? logoutButton
        UIView.animate {
            button.isHidden = !session.hasSession(with: Email(savedEmail))
            button.alpha = button.isHidden ? 0 : 1
        }
    }

    func logout() {
        guard let savedEmail else { return }
        let session = OAuthSession()
        session.deleteSession(with: Email(savedEmail))
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

    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailField,
            tokenField,
            profileSummaryView,
            colorSchemeLabel,
            schemeToggle,
            layoutButton,
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
    }

    func presentQuickEditor() {
        guard let email = emailField.text else { return }
        savedEmail = email
        let presenter = QuickEditorPresenter(
            email: Email(email),
            scope: .avatarPicker(AvatarPickerConfiguration(contentLayout: selectedLayout.contentLayout)),
            configuration: .init(
                interfaceStyle: customColorScheme
            ),
            token: token
        )
        presenter.present(in: self, onAvatarUpdated: { [weak self] in
            self?.profileSummaryView.loadAvatar(with: .email(email), options: [.forceRefresh])
        } , onDismiss: { [weak self] in
            self?.updateLogoutButton()
        })
    }
}

extension DemoQuickEditorViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == emailField, let emailText = textField.text, Email(emailText).isValid {
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
