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

    lazy var emailField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textContentType = .emailAddress
        field.keyboardType = .emailAddress
        field.borderStyle = .roundedRect
        field.placeholder = "email"
        field.delegate = self
        field.text = savedEmail
        return field
    }()

    var selectedLayout: QELayoutOptions = .horizontal {
        didSet {
            layoutButton.setTitle(selectedLayout.rawValue, for: .normal)
        }
    }

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

    lazy var showButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Quick Editor", for: .normal)
        button.addAction(UIAction { [weak self] _ in self?.presentQuickEditor() }, for: .touchUpInside)
        button.isEnabled = savedEmail != nil
        return button
    }()

    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailField, layoutButton, showButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 0, left: 24, bottom: 0, right: 24)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    func presentQuickEditor() {
        guard let email = emailField.text else { return }
        savedEmail = email
        let quickEditor = QuickEditorViewController(
            email: Email(email),
            scope: .avatarPicker,
            avatarPickerConfiguration: AvatarPickerConfiguration(contentLayout: selectedLayout.contentLayout)
        )
        present(quickEditor, animated: true)
    }
}

extension DemoQuickEditorViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        showButton.isEnabled = Email(textField.text ?? "").isValid
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

enum QELayoutOptions: String, Identifiable, CaseIterable {
    var id: String { rawValue }

    case verticalLarge = "vertical - large"
    case verticalExpandable = "vertical - expandable"
    case verticalExpandablePrioritizeScrolling = "vertical - expandable - prioritize scrolling"
    case horizontal = "horizontal"

    var contentLayout: AvatarPickerContentLayoutWithPresentation {
        switch self {
        case .verticalLarge:
                .vertical(presentationStyle: .large)
        case .verticalExpandable:
                .vertical(presentationStyle: .expandableMedium())
        case .verticalExpandablePrioritizeScrolling:
                .vertical(presentationStyle: .expandableMedium(prioritizeScrollOverResize: true))
        case .horizontal:
                .horizontal()
        }
    }
}
