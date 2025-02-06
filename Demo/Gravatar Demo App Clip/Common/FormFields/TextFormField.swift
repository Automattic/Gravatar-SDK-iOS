import UIKit
import Combine

class TextFormField: FormField, @unchecked Sendable, UITextFieldDelegate {
    let placeholder: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool

    @Published var text: String
    @Published var didEndEditingText: String = ""

    private let cellID = "TextFieldCell"

    init(placeholder: String, text: String = "", isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        self.text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
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
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditingText = textField.text ?? ""
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with config: TextFormField) {
        textField.placeholder = config.placeholder
        textField.text = config.text
        textField.keyboardType = config.keyboardType
        textField.isSecureTextEntry = config.isSecure
    }
}
