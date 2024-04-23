import Gravatar
import UIKit

open class BaseProfileView: UIView, UIContentView {
    enum Constants {
        static let avatarLength: CGFloat = 72
        static let maximumAccountsDisplay = 4
        static let accountIconLength: CGFloat = 32
        static let defaultDisplayNamePlaceholderHeight: CGFloat = 24
    }

    open var avatarLength: CGFloat {
        Constants.avatarLength
    }

    public enum PlaceholderColorPolicy {
        /// Gets the placeholder colors from the current palette.
        case currentPalette
        /// Custom colors. You can also pass predefined colors from any ``Palette``. Example:  `PaletteType.light.palette.placeholder`.
        case custom(PlaceholderColors)
    }

    /// Placeholder color policy to use in the placeholder state (which basically means when all fields are empty).
    public var placeholderColorPolicy: PlaceholderColorPolicy = .currentPalette {
        didSet {
            placeholderDisplayer?.refresh(with: placeholderColors)
        }
    }

    /// Displays a placeholder when all the fields are empty. Defaults to `ProfileViewPlaceholderDisplayer`. Set  to`nil` for not using any.
    public var placeholderDisplayer: ProfileViewPlaceholderDisplaying?

    /// Activity indicator to show when `isLoading` is `true` .
    /// Defaults to ``ProfilePlaceholderActivityIndicator``.
    public var activityIndicator: (any ProfileActivityIndicator)?

    public var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            if isLoading {
                activityIndicator?.startAnimating(on: self)
            } else {
                activityIndicator?.stopAnimating(on: self)
            }
        }
    }

    public var profileButtonStyle: ProfileButtonStyle = .view {
        didSet {
            Configure(profileButton).asProfileButton().style(profileButtonStyle)
        }
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

    var accounts: [AccountModel] = []
    var maximumAccountsDisplay = Constants.maximumAccountsDisplay
    var model: ProfileSummaryModel? {
        didSet {
            if model == nil {
                clearFields()
            }
            togglePlaceholder()
        }
    }

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
        imageView.widthAnchor.constraint(equalToConstant: avatarLength).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: avatarLength).isActive = true
        imageView.layer.cornerRadius = avatarLength / 2
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return imageView
    }()

    public private(set) lazy var aboutMeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    /// The placeholder state of "about me" label consists of 2 separate lines in some designs. This label's only purpose is to serve as the 2nd line of that
    /// placeholder.
    lazy var aboutMePlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.isHidden = true
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
        let action = UIAction { [weak self] action in
            self?.onProfileButtonPressed(with: action)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()

    public let accountButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = .DS.Padding.half
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return stack
    }()

    public var paletteType: PaletteType {
        didSet {
            refresh(with: paletteType)
        }
    }

    override public init(frame: CGRect) {
        self.paletteType = .system
        let placeholderDisplayer = ProfileViewPlaceholderDisplayer()
        self.placeholderDisplayer = placeholderDisplayer
        self.activityIndicator = ProfilePlaceholderActivityIndicator(placeholderDisplayer: placeholderDisplayer)
        super.init(frame: frame)
        self.padding = Self.defaultPadding
        commonInit()
    }

    public convenience init(
        frame: CGRect,
        paletteType: PaletteType? = nil,
        profileButtonStyle: ProfileButtonStyle? = nil,
        padding: UIEdgeInsets? = nil
    ) {
        self.init(frame: frame)
        self.paletteType = paletteType ?? self.paletteType
        self.profileButtonStyle = profileButtonStyle ?? self.profileButtonStyle
        self.padding = padding ?? Self.defaultPadding
        refresh(with: self.paletteType)
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
        placeholderDisplayer?.setup(using: self)
        arrangeSubviews()
        togglePlaceholder() // We should call this after subviews are added (which means after `arrangeSubviews()`)
    }

    open func arrangeSubviews() {
        assertionFailure("Subviews must override this to add necessary UI elements to the `rootStackView`")
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func loadAvatar(
        with avatarIdentifier: AvatarIdentifier,
        placeholder: UIImage? = nil,
        rating: Rating? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        options: [ImageSettingOption]? = nil,
        completionHandler: ImageSetCompletion? = nil
    ) {
        avatarImageView.gravatar.setImage(
            avatarID: avatarIdentifier,
            placeholder: placeholder,
            rating: rating,
            preferredSize: CGSize(width: avatarLength, height: avatarLength),
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
        placeholderDisplayer?.refresh(with: placeholderColors)
    }

    func updateAccountButtons(with model: AccountListModel?) {
        accounts = Array(model?.accountsList.prefix(Constants.maximumAccountsDisplay) ?? [])
        let buttons = accounts.map(createAccountButton)
        for view in accountButtonsStackView.arrangedSubviews {
            accountButtonsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        buttons.forEach(accountButtonsStackView.addArrangedSubview)
    }

    func createAccountButton(model: AccountModel) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.profileView(self, didTapOnAccountButtonWithModel: model)
        }
        button.addAction(action, for: .touchUpInside)

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
        isLoading = config.isLoading
        if let avatarID = config.avatarID {
            loadAvatar(with: avatarID)
        }
        if config.model != nil || config.summaryModel != nil {
            profileButtonStyle = config.profileButtonStyle
        }
    }

    private func onProfileButtonPressed(with action: UIAction) {
        let url = profileButtonStyle == .edit ? self.model?.profileEditURL : self.model?.profileURL
        self.delegate?.profileView(
            self,
            didTapOnProfileButtonWithStyle: profileButtonStyle,
            profileURL: url
        )
    }

    // MARK: - Placeholder handling

    var placeholderColors: PlaceholderColors {
        switch placeholderColorPolicy {
        case .currentPalette:
            paletteType.palette.placeholder
        case .custom(let placeholderColors):
            placeholderColors
        }
    }

    open var displayNamePlaceholderHeight: CGFloat {
        Constants.defaultDisplayNamePlaceholderHeight
    }

    func clearFields() {
        displayNameLabel.text = nil
        personalInfoLabel.text = nil
        aboutMeLabel.text = nil
        updateAccountButtons(with: nil)
        avatarImageView.image = nil
    }

    var shouldShowPlaceholder: Bool {
        model == nil
    }

    func togglePlaceholder() {
        if shouldShowPlaceholder {
            showPlaceholders()
        } else {
            hidePlaceholders()
        }
    }

    open func showPlaceholders() {
        placeholderDisplayer?.showPlaceholder(on: self)
    }

    open func hidePlaceholders() {
        placeholderDisplayer?.hidePlaceholder(on: self)
    }
}

public protocol ProfileViewDelegate: NSObjectProtocol {
    func profileView(_ view: BaseProfileView, didTapOnProfileButtonWithStyle style: ProfileButtonStyle, profileURL: URL?)
    func profileView(_ view: BaseProfileView, didTapOnAccountButtonWithModel accountModel: AccountModel)
}
