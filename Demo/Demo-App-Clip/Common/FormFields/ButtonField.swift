import UIKit

final class ButtonField: FormField, @unchecked Sendable {
    var title: String
    var isActionButton: Bool
    var isEnabled: Bool

    private let cellID = "ButtonCell"
    private let action: UIAction

    @MainActor
    init(title: String, isActionButton: Bool = false, enabled: Bool = true, action actionHandler: @escaping UIActionHandler) {
        self.title = title
        self.isActionButton = isActionButton
        self.isEnabled = enabled
        self.action = UIAction(handler: actionHandler)
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? ButtonCell ?? ButtonCell(reuseIdentifier: cellID)
        cell.update(with: self)
        cell.button.removeAllActions()
        cell.button.addAction(action, for: .touchUpInside)
        return cell
    }
}

private final class ButtonCell: UITableViewCell {
    let button = UIButton()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        button.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(button)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: button.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with field: ButtonField) {
        var config = field.isActionButton ? UIButton.Configuration.borderedProminent() : .plain()
        config.title = field.title
        button.configuration = config
        button.isEnabled = field.isEnabled
        button.sizeToFit()
    }
}

