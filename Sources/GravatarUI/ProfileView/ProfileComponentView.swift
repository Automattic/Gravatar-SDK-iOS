import Gravatar
import UIKit

open class ProfileComponentView: UIView, UIContentView {
    private enum Constants {
        static let avatarLength: CGFloat = 72
        static let maximumAccountsDisplay = 4
        static let accountIconLength: CGFloat = 32
    }

    static let defaultPadding = UIEdgeInsets(
        top: .DS.Padding.split,
        left: .DS.Padding.medium,
        bottom: .DS.Padding.split,
        right: .DS.Padding.medium
    )

    public var configuration: UIContentConfiguration = ProfileViewConfiguration(model: nil, palette: .system, profileStyle: .standard) {
        didSet {
            guard let config = configuration as? ProfileViewConfiguration else {
                return
            }
            update(with: config)
        }
    }

    public weak var delegate: ProfileViewDelegate?

    var profileMetadata: ProfileMetadataModel?
    var accounts: [AccountModel] = []
    var maximumAccountsDisplay = Constants.maximumAccountsDisplay

    var padding: UIEdgeInsets {
        get {
            // layoutMargins is automatically synced with directionalLayoutMargins
            layoutMargins
        }
        set {
            directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: newValue.top,
                leading: newValue.left,
                bottom: newValue.bottom,
                trailing: newValue.right
            )
            layoutMarginsDidChange()
        }
    }

    public lazy var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = .DS.Padding.single
        return stack
    }()

    public private(set) lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: Constants.avatarLength).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.avatarLength).isActive = true
        imageView.layer.cornerRadius = Constants.avatarLength / 2
        imageView.clipsToBounds = true
        return imageView
    }()

    public private(set) lazy var aboutMeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    public private(set) lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    public private(set) lazy var personalInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    public lazy var profileButton: UIButton = {
        let button = UIButton(configuration: .borderless())
        button.addTarget(self, action: #selector(onProfileButtonTap), for: .touchUpInside)
        return button
    }()

    public let accountButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = .DS.Padding.half
        return stack
    }()

    public var paletteType: PaletteType {
        didSet {
            refresh(with: paletteType)
        }
    }

    override public init(frame: CGRect) {
        self.paletteType = .system
        super.init(frame: frame)
    }

    public init(frame: CGRect, paletteType: PaletteType, padding: UIEdgeInsets?) {
        self.paletteType = paletteType
        super.init(frame: frame)
        commonInit()
        self.padding = padding ?? Self.defaultPadding
    }

    func commonInit() {
        addSubview(rootStackView)
        NSLayoutConstraint.activate([
            layoutMarginsGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            layoutMarginsGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
        refresh(with: paletteType)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func loadAvatar(
        with avatarIdentifier: AvatarIdentifier,
        placeholder: UIImage? = nil,
        rating: Rating? = nil,
        preferredSize: CGSize? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        options: [ImageSettingOption]? = nil,
        completionHandler: ImageSetCompletion? = nil
    ) {
        avatarImageView.gravatar.setImage(
            avatarID: avatarIdentifier,
            placeholder: placeholder,
            rating: rating,
            preferredSize: preferredSize ?? CGSize(width: Constants.avatarLength, height: Constants.avatarLength),
            defaultAvatarOption: defaultAvatarOption,
            options: options
        ) { [weak self] result in
            switch result {
            case .success:
                self?.avatarImageView.layer.borderColor = self?.paletteType.palette.avatarBorder.cgColor
                self?.avatarImageView.layer.borderWidth = 1
            default:
                self?.avatarImageView.layer.borderColor = UIColor.clear.cgColor
            }
            completionHandler?(result)
        }
    }

    func refresh(with paletteType: PaletteType) {
        avatarImageView.layer.borderColor = paletteType.palette.avatarBorder.cgColor
        backgroundColor = paletteType.palette.background.primary
        Configure(aboutMeLabel).asAboutMe().palette(paletteType)
        Configure(displayNameLabel).asDisplayName().palette(paletteType)
        Configure(personalInfoLabel).asPersonalInfo().palette(paletteType)

        Configure(profileButton).asProfileButton().palette(paletteType)

        accountButtonsStackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
            Configure(button).asAccountButton().palette(paletteType)
        }
    }

    func updateAccountButtons(with model: AccountListModel) {
        accounts = Array(model.accountsList.prefix(4))
        let buttons = accounts.enumerated().map(createAccountButton)
        for view in accountButtonsStackView.arrangedSubviews {
            accountButtonsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        buttons.forEach(accountButtonsStackView.addArrangedSubview)
    }

    func createAccountButton(index: Int, model: AccountModel) -> UIButton {
        let button = UIButton()
        button.tag = index
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onAccountButtonTap), for: .touchUpInside)
        Configure(button).asAccountButton().content(model).palette(paletteType)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        if let imageView = button.imageView {
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: Constants.accountIconLength),
                button.heightAnchor.constraint(equalToConstant: Constants.accountIconLength),
                imageView.widthAnchor.constraint(equalToConstant: Constants.accountIconLength),
                imageView.heightAnchor.constraint(equalToConstant: Constants.accountIconLength),
            ])
        }
        return button
    }

    open func update(with config: ProfileViewConfiguration) {
        paletteType = config.palette
        padding = config.padding
        if let avatarID = config.avatarID {
            loadAvatar(with: avatarID)
        }
    }

    @objc func onAccountButtonTap(_ button: UIButton) {
        let index = button.tag
        guard let delegate, index >= 0, index < accounts.count else { return }
        let account = accounts[index]
        delegate.didTapOnAccountButton(with: account)
    }

    @objc func onProfileButtonTap() {
        delegate?.didTapOnProfileButton(with: .view, profileURL: profileMetadata?.profileURL)
    }
}

public protocol ProfileViewDelegate: NSObjectProtocol {
    func didTapOnProfileButton(with style: ProfileButtonStyle, profileURL: URL?)
    func didTapOnAccountButton(with accountModel: AccountModel)
}
