import UIKit
import Combine

@MainActor
protocol TextFormFieldDelegate: NSObjectProtocol {
    func textFormDidChangeSelection(_ textForm: TextFormField)

    func textFormShouldReturn(_ textForm: TextFormField) -> Bool

    func textFormDidEndEditing(_ textForm: TextFormField)
}

class TextFormField: FormField, @unchecked Sendable, UITextFieldDelegate {
    let placeholder: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    weak var delegate: TextFormFieldDelegate?

    @Published var text: String
    @Published var didEndEditingText: String = ""

    private let cellID = "TextFieldCell"

    init(placeholder: String, text: String = "", isSecure: Bool = false, keyboardType: UIKeyboardType = .default, delegate: TextFormFieldDelegate? = nil) {
        self.text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.delegate = delegate
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? TextFieldCell ?? TextFieldCell(reuseIdentifier: cellID)
        cell.textField.delegate = self
        cell.update(with: self)
        return cell
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        text = textField.text ?? ""
        delegate?.textFormDidChangeSelection(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return delegate?.textFormShouldReturn(self) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditingText = textField.text ?? ""
        delegate?.textFormDidEndEditing(self)
    }
}

private final class TextFieldCell: UITableViewCell {
    let textField = UITextField()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.autocapitalizationType = .none

        self.contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            contentView.readableContentGuide.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            contentView.readableContentGuide.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: textField.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
        ])
    }

    func addShowPasswordButton() {
        let showButton = UIButton(type: .custom, primaryAction: UIAction { [weak self] action in
            guard let self else { return }
            textField.isSecureTextEntry = !textField.isSecureTextEntry
            (action.sender as? UIButton)?.isSelected = !textField.isSecureTextEntry
        })
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .systemGray
        showButton.configuration = config

        showButton.configurationUpdateHandler = { button in
            switch button.state {
                case .normal:
                button.configuration?.image = UIImage(systemName: "eye")
            case .selected:
                button.configuration?.image = UIImage(systemName: "eye.slash")
                button.configuration?.baseBackgroundColor = .clear
            default: break
            }
        }

        textField.rightView = showButton
        textField.rightViewMode = .always
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with config: TextFormField) {
        textField.placeholder = config.placeholder
        textField.text = config.text
        textField.keyboardType = config.keyboardType
        textField.isSecureTextEntry = config.isSecure
        if config.isSecure {
            addShowPasswordButton()
        } else {
            textField.rightView = nil
        }
    }
}
