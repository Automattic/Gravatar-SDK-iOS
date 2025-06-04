import UIKit

final class ButtonLabelField: FormField, @unchecked Sendable {
    var buttonTitle: String
    var title: String
    var subtitle: String?
    var isEnabled: Bool
    var selectedMenuActionTitle: String?

    private let cellID = "ButtonCellCell"
    @MainActor
    private let action: UIAction?
    private let menuActions: [UIMenuElement]?

    @MainActor
    init(title: String, subtitle: String? = nil, buttonTitle: String, isEnabled: Bool = true, action actionHandler: @escaping UIActionHandler) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.isEnabled = isEnabled
        self.action = UIAction(handler: actionHandler)
        self.menuActions = nil
    }

    @MainActor
    init(title: String, subtitle: String? = nil, buttonTitle: String, isEnabled: Bool = true, menuActions: [UIMenuElement], selectedMenuActionTitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.isEnabled = isEnabled
        self.menuActions = menuActions
        self.action = nil
        self.selectedMenuActionTitle = selectedMenuActionTitle
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? ButtonLabelCell ?? ButtonLabelCell(reuseIdentifier: cellID)
        cell.update(with: self)

        cell.button.removeAllActions()
        cell.button.menu = nil
        cell.button.showsMenuAsPrimaryAction = false

        if let action {
            cell.button.addAction(action, for: .touchUpInside)
        } else if let menuActions {
            cell.button.menu = UIMenu(children: menuActions.compactMap {
                guard let action = $0 as? UIAction else { return $0 }
                if action.title == selectedMenuActionTitle {
                    action.state = .on
                    return action
                } else {
                    action.state = .off
                    return $0
                }
            })
            cell.button.showsMenuAsPrimaryAction = true
        }
        return cell
    }
}

private final class ButtonLabelCell: UITableViewCell {
    let button = UIButton()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        accessoryView = button
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with field: ButtonLabelField) {
        var config = UIButton.Configuration.plain()
        config.title = field.buttonTitle
        button.configuration = config
        button.sizeToFit()
        button.isEnabled = field.isEnabled

        var cellConfig = self.defaultContentConfiguration()
        cellConfig.text = field.title
        cellConfig.secondaryText = field.subtitle

        self.contentConfiguration = cellConfig
    }
}
