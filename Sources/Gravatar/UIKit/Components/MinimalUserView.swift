import UIKit

public class MinimalUserView: UIView, UIContentView {
    public var layoutConfiguration: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            switch layoutConfiguration {
            case .horizontal:
//                configureHorizontal()
                break
            case .vertical:
                configureVertical()
            @unknown default:
                break
            }
        }
    }

    func configureVertical() {
        rootStackView.axis = .vertical
        rootStackView.alignment = .center
        rootStackView.distribution = .equalCentering
        textStackView.alignment = .center
        rootStackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20)
    }

    public var configuration: UIContentConfiguration = MinimalUserConfiguration.empty {
        didSet {
            configure(with: configuration)
        }
    }

    public var defaultConfiguration: MinimalUserConfiguration {
        .empty
    }

    let imageView: UserImageView = {
        let imageView = UserImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.backgroundColor = .systemGray6
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title2)
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 12
        return stackView
    }()

    lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView
    }()

    func makeSpacer() -> UIView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        return spacer
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    public init() {
        super.init(frame: .zero)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func loadInformation(for email: String) async throws {
        imageView.setImage(email: email)
        let profile = try await ProfileService().fetchProfile(for: email)
        nameLabel.text = profile.displayName
        detailLabel.text = profile.aboutMe
    }

    func configureUI() {
        addSubview(rootStackView)
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func configure(with configuration: UIContentConfiguration) {
        guard let configuration = configuration as? MinimalUserConfiguration else {
            return
        }
        imageView.setImage(
            email: configuration.email ?? "",
            placeholder: configuration.placeholderImage,
            preferredSize: CGSize(width: 60, height: 60)
        )
        nameLabel.text = configuration.userName
        detailLabel.text = configuration.detail
    }
}

public struct MinimalUserConfiguration: UIContentConfiguration {
    public var email: String?
    public var userName: String
    public var detail: String
    public var placeholderImage: UIImage?

    public static var empty: MinimalUserConfiguration {
        MinimalUserConfiguration(email: "", userName: "", detail: "", placeholderImage: nil)
    }

    init(email: String?, userName: String, detail: String, placeholderImage: UIImage?) {
        self.email = email
        self.userName = userName
        self.detail = detail
        self.placeholderImage = placeholderImage
    }

    public func makeContentView() -> UIView & UIContentView {
        let userView = MinimalUserView()
        userView.configuration = self
        return userView
    }

    public func updated(for state: UIConfigurationState) -> MinimalUserConfiguration {
        self
    }
}
