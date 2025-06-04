import UIKit
import Combine

struct FormSection: SectionTitle, Hashable {
    var sectionTitle: String
}

class FormField: NSObject, @unchecked Sendable {
    @MainActor
    func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell { fatalError() }
}

class BaseFormViewController: UITableViewController {
    @Published var fieldText: String = ""

    var cancellables = Set<AnyCancellable>()

    let section = FormSection(sectionTitle: "")

    var snapshot = NSDiffableDataSourceSnapshot<FormSection, FormField>()
    lazy var dataSource: UITableViewDiffableDataSource = SectionTitleTableViewDiffibleDataSource<FormSection, FormField>(tableView: tableView) {
        (tableView: UITableView, indexPath: IndexPath, formField: FormField) -> UITableViewCell? in
        let cell = formField.dequeueCell(in: tableView, for: indexPath)
        cell.backgroundView?.backgroundColor = .secondarySystemBackground
        cell.backgroundColor = .secondarySystemBackground
        cell.contentView.backgroundColor = .secondarySystemBackground
        cell.accessoryView?.backgroundColor = .secondarySystemBackground
        return cell
    }

    var form: [FormField] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        snapshot.appendSections([section])
        snapshot.appendItems(form)
        dataSource.apply(snapshot)
        view.backgroundColor = .secondarySystemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delaysContentTouches = false
        dataSource.defaultRowAnimation = .fade
    }

    func replace(_ oldFormField: FormField, with newFormField: FormField, after: FormField) {
        snapshot.deleteItems([oldFormField])
        if snapshot.indexOfItem(newFormField) == nil {
            snapshot.insertItems([newFormField], afterItem: after)
        }
        dataSource.apply(snapshot)
    }

    func update(_ field: FormField, animated: Bool = false) {
        update([field], animated: animated)
    }

    func update(_ fields: [FormField], animated: Bool = false) {
        guard Set(snapshot.itemIdentifiers).isSuperset(of: fields) else { return }
        snapshot.reloadItems(fields)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func remove(fields: [FormField]) {
        fields.forEach {
            if snapshot.indexOfItem($0) != nil {
                snapshot.deleteItems([$0])
            }
        }
    }

    func add(fields: [FormField], after: FormField? = nil) {
        fields.forEach {
            if snapshot.indexOfItem($0) == nil {
                if let after {
                    snapshot.insertItems([$0], afterItem: after)
                } else {
                    snapshot.appendItems([$0])
                }
            }
        }
    }

    func commitUpdates() {
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

class SectionTitleTableViewDiffibleDataSource<SectionType: Hashable, ItemType: Hashable>: UITableViewDiffableDataSource<SectionType, ItemType> where SectionType: SectionTitle, SectionType: Sendable, ItemType: Sendable {

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionIdentifier(for: section)?.sectionTitle
    }
}

protocol SectionTitle {
    var sectionTitle: String { get }
}

extension UIControl {
    func removeAllActions() {
        enumerateEventHandlers { action, _, event, _ in
            if let action = action {
                removeAction(action, for: event)
            }
        }
    }
}
