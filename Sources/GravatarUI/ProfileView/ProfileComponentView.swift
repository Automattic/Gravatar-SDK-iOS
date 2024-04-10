import Gravatar
import UIKit

open class ProfileComponentView: UIView {
    private enum Constants {
        static let avatarLength: CGFloat = 72
        static let maximumAccountsDisplay = 3
    }

    var maximumAccountsDisplay = Constants.maximumAccountsDisplay

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
        var config = UIButton.Configuration.borderless()

        let button = UIButton(configuration: config)

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
        addSubview(rootStackView)
        layoutMargins = UIEdgeInsets(
            top: .DS.Padding.medium,
            left: .DS.Padding.medium,
            bottom: .DS.Padding.medium,
            right: .DS.Padding.medium
        )
        NSLayoutConstraint.activate([
            layoutMarginsGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            layoutMarginsGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
    }

    public convenience init(frame: CGRect, paletteType: PaletteType) {
        self.init(frame: frame)
        self.paletteType = paletteType
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

        var config = profileButton.configuration
        config?.baseForegroundColor = paletteType.palette.foreground.primary
        profileButton.configuration = config
    }

    func updateAccountButtons(with model: AccountListModel) {
        let buttons = model.accountsList?.prefix(maximumAccountsDisplay).map(createAccountButton)
        for view in accountButtonsStackView.arrangedSubviews {
            accountButtonsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        accountButtonsStackView.addArrangedSubview(createAccountButton(with: model.gravatarAccount))
        buttons?.forEach(accountButtonsStackView.addArrangedSubview)
    }

    func createAccountButton(with model: AccountModel) -> UIButton {
        let button = UIButton()
        Configure(button).asAccountButton().content(model).palette(paletteType)
        return button
    }
}
