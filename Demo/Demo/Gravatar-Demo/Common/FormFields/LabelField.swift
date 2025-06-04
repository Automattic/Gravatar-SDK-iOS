import UIKit

final class LabelField: FormField, @unchecked Sendable {
    var title: String?
    var subtitle: String?
    var titleStyle: UIFont.TextStyle

    private let cellID = "LabelCell"

    init(title: String? = nil, subtitle: String? = nil, style: UIFont.TextStyle = .body) {
        self.title = title
        self.subtitle = subtitle
        self.titleStyle = style
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)

        var config = cell.defaultContentConfiguration()
        config.text = title
        config.textProperties.font = UIFont.preferredFont(forTextStyle: titleStyle)
        config.secondaryText = subtitle
        cell.contentConfiguration = config

        return cell
    }
}
