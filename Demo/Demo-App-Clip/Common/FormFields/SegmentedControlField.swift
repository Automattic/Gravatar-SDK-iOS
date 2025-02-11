import UIKit

class SegmentedControlField: FormField, @unchecked Sendable, UITextFieldDelegate {
    typealias OnSegmentSelected = (String, Int) -> Void

    var segments: [String]
    let actionHandler: OnSegmentSelected?

    @Published var selectedIndex: Int
    @Published var selectedSegment: String = ""

    private let cellID = "ImageFormCell"

    init(segments: [String], selectedIndex: Int = 0, action actionhandler: OnSegmentSelected? = nil) {
        self.segments = segments
        self.selectedIndex = selectedIndex
        self.actionHandler = actionhandler
        if segments.indices.contains(selectedIndex) {
            selectedSegment = segments[selectedIndex]
        }
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? SegmentedControlCell ?? SegmentedControlCell(reuseIdentifier: cellID)
        cell.update(with: self)
        cell.selector.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            selectedIndex = cell.selector.selectedSegmentIndex
            selectedSegment = segments[selectedIndex]
            actionHandler?(selectedSegment, selectedIndex)
        }, for: .valueChanged)
        return cell
    }
}

private final class SegmentedControlCell: UITableViewCell {
    let selector = UISegmentedControl()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selector.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(selector)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: selector.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: selector.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: selector.bottomAnchor, constant: 8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with config: SegmentedControlField) {
        selector.removeAllSegments()
        config.segments.enumerated().forEach {
            selector.insertSegment(withTitle: $1, at: $0, animated: true)
        }
        selector.selectedSegmentIndex = config.selectedIndex
    }
}
