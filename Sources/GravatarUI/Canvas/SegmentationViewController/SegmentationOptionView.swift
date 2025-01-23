import UIKit

class SegmentationOptionView: UIView {
    private let imageView = UIImageView()
    private let label = UILabel()

    // Store the associated type for identification
    let option: SegmentationOption

    // Track selected state
    var isOptionSelected: Bool = false {
        didSet {
            updateSelectedAppearance()
        }
    }

    init(option: SegmentationOption) {
        self.option = option
        super.init(frame: .zero)
        setupView()
        updateSelectedAppearance()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8

        imageView.contentMode = .scaleAspectFit
        imageView.image = option.icon

        label.text = option.title
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        // Constrain stack to fill entire view
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 32),
        ])

        // Style
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = .systemGray6
    }

    private func updateSelectedAppearance() {
        // For example, change background color if selected
        if isOptionSelected {
            backgroundColor = .systemBlue
            label.textColor = .white
            imageView.tintColor = .white
        } else {
            backgroundColor = .systemGray6
            label.textColor = .label
            imageView.tintColor = .label
        }
    }
}
