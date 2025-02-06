import UIKit
import Combine

final class SwitchField: FormField, @unchecked Sendable {
    typealias OnSwitchValueChange = (Bool) -> Void
    @Published var isOn: Bool
    let title: String
    private let cellID = "SwitchCell"
    private var cancellables = Set<AnyCancellable>()
    private var actionHandler: OnSwitchValueChange?

    init(title: String, isOn: Bool = false, action actionHandler: OnSwitchValueChange? = nil) {
        self.isOn = isOn
        self.title = title
        self.actionHandler = actionHandler
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? SwitchCell ?? SwitchCell(reuseIdentifier: cellID)
        cell.update(with: self)

        cell.switcher.removeAllActions()
        cell.switcher.addAction(UIAction { [weak self] _ in
            self?.isOn = cell.switcher.isOn
            self?.actionHandler?(cell.switcher.isOn)
        }, for: .valueChanged)

        return cell
    }
}

private final class SwitchCell: UITableViewCell {
    let switcher = UISwitch()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.accessoryView = switcher
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with config: SwitchField) {
        self.textLabel?.text = config.title
        if switcher.isOn != config.isOn {
            switcher.setOn(config.isOn, animated: true)
        }
    }
}
