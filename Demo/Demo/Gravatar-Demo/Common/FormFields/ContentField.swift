import UIKit

final class ContentField: FormField, @unchecked Sendable {
    var contentConfig: UIContentConfiguration

    private let cellID = "ContentConfigurationCell"

    init(contentConfig: UIContentConfiguration) {
        self.contentConfig = contentConfig
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? ViewCell ?? ViewCell(reuseIdentifier: cellID)
        cell.update(with: contentConfig)
        return cell
    }
}

private final class ViewCell: UITableViewCell {
    var horizontalContentInset: CGFloat = 20

    override var frame: CGRect {
        get {
            super.frame
        }
        set {
            guard let superview else {
                super.frame = newValue
                return
            }
            // Adds readable content margins to the UIContentView.
            var frame = newValue
            frame.origin.x = superview.readableContentGuide.layoutFrame.minX
            frame.size.width = superview.readableContentGuide.layoutFrame.width
            super.frame = frame
        }
    }

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with config: UIContentConfiguration) {
        self.contentConfiguration = config
    }
}
