import UIKit
import Combine

class ImageFormField: FormField, @unchecked Sendable, UITextFieldDelegate {
    var image: UIImage?
    var size: CGSize
    private(set) var imageView: UIImageView?
    private var cancellables = Set<AnyCancellable>()

    private let cellID = "ImageFormCell"

    init(image: UIImage? = nil, size: CGSize) {
        self.image = image
        self.size = size
    }

    @MainActor
    override func dequeueCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? ImageCell ?? ImageCell(reuseIdentifier: cellID)
        cell.update(with: self)
        imageView = cell.formImageView
        cell.formImageView.publisher(for: \.image).sink { [weak self] image in
            self?.image = image
        }.store(in: &cancellables)

        return cell
    }
}

private final class ImageCell: UITableViewCell {
    let formImageView = UIImageView()

    private lazy var widthConstraint: NSLayoutConstraint = formImageView.widthAnchor.constraint(equalToConstant: 300)
    private lazy var heightConstraint: NSLayoutConstraint = formImageView.heightAnchor.constraint(equalToConstant: 300)

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        formImageView.translatesAutoresizingMaskIntoConstraints = false
        formImageView.backgroundColor = .tertiarySystemBackground

        self.contentView.addSubview(formImageView)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: formImageView.centerXAnchor),
            contentView.topAnchor.constraint(equalTo: formImageView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: formImageView.bottomAnchor, constant: 8),
            widthConstraint,
            heightConstraint
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with config: ImageFormField) {
        widthConstraint.constant = config.size.width
        heightConstraint.constant = config.size.height
        if let image = config.image {
            formImageView.image = image
        }
    }
}
