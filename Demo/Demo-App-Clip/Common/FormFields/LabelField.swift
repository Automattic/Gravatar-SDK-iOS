import UIKit

final class LabelField: FormField, @unchecked Sendable {
    var title: String?
    var subtitle: String?
    private let cellID = "LabelCell"

    init(title: String? = nil, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)

        var config = cell.defaultContentConfiguration()
        config.text = title
        config.secondaryText = subtitle
        cell.contentConfiguration = config

        return cell
    }
}
