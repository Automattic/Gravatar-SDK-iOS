import Gravatar
import UIKit

open class BaseProfileView: UIView, UIContentView {
    enum Constants {
        static let avatarLength: CGFloat = 72
        static let maximumAccountsDisplay = 4
        static let accountIconLength: CGFloat = 32
        static let defaultDisplayNamePlaceholderHeight: CGFloat = 24
    }

    open class var avatarLength: CGFloat {
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
            placeholderDisplayer?.refresh(with: placeholderColors, paletteType: paletteType)
        }
    }

    /// Displays a placeholder when all the fields are empty. Defaults to `ProfileViewPlaceholderDisplayer`. Set  to`nil` for not using any.
    public var placeholderDisplayer: ProfileViewPlaceholderDisplaying?

    /// Activity indicator to show when `isLoading` is `true` .
    /// Defaults to ``ProfilePlaceholderActivityIndicator``.
    public var activityIndicator: (any ProfileActivityIndicator)?

    /// Avatar's activity indicator to show while downloading an image.
    public var avatarActivityIndicatorType: ActivityIndicatorType = .activity {
        didSet {
            if let provider = avatarProvider as? DefaultAvatarProvider {
                provider.activityIndicatorType = avatarActivityIndicatorType
            }
        }
    }

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
            Configure(profileButton).asProfileButton().style(profileButtonStyle).palette(paletteType)
            aboutMeDashedLabel.showDashedBorder = profileButtonStyle == .create
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

    /// Provides the avatar to show in this view.
    let avatarProvider: AvatarProviding

    /// Type of the avatar. See: ``AvatarType``.
    public let avatarType: AvatarType

    public var avatarView: UIView {
        avatarProvider.avatarView
    }

    public var avatarImageView: UIImageView? {
        avatarType.imageView
    }

    let aboutMeDashedLabel: DashedLabel = {
        let label = DashedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    public var aboutMeLabel: UILabel {
        aboutMeDashedLabel
    }

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

    public init(
        frame: CGRect = .zero,
        paletteType: PaletteType? = nil,
        profileButtonStyle: ProfileButtonStyle? = nil,
        avatarType: AvatarType? = nil,
        padding: UIEdgeInsets? = nil
    ) {
        self.paletteType = paletteType ?? .system
        let placeholderDisplayer = ProfileViewPlaceholderDisplayer()
        self.placeholderDisplayer = placeholderDisplayer
        self.activityIndicator = ProfilePlaceholderActivityIndicator(placeholderDisplayer: placeholderDisplayer)
        self.avatarType = (avatarType ?? AvatarType.imageView(UIImageView()))
        self.avatarProvider = self.avatarType.avatarProvider(avatarLength: Self.avatarLength, paletteType: self.paletteType)
        self.profileButtonStyle = profileButtonStyle ?? self.profileButtonStyle
        super.init(frame: frame)
        self.padding = padding ?? Self.defaultPadding
        commonInit()
    }

    func commonInit() {
        addSubview(rootStackView)
        NSLayoutConstraint.activate([
            layoutMarginsGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            layoutMarginsGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
        if let defaultAvatarProvider = avatarProvider as? DefaultAvatarProvider {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
            defaultAvatarProvider.avatarView.addGestureRecognizer(tapGestureRecognizer)
            defaultAvatarProvider.avatarView.isUserInteractionEnabled = true
        }
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
        with avatarIdentifier: AvatarIdentifier?,
        placeholder: UIImage? = nil,
        rating: Rating? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        options: [ImageSettingOption]? = nil
    ) {
        guard let avatarIdentifier else {
            avatarProvider.setImage(placeholder)
            return
        }
        let pointsSize: ImageSize = .points(Self.avatarLength)
        let downloadOptions = ImageSettingOptions(options: options).deriveDownloadOptions(
            garavatarRating: rating,
            preferredSize: pointsSize,
            defaultAvatarOption: defaultAvatarOption
        )

        let gravatarURL = AvatarURL(with: avatarIdentifier, options: downloadOptions.avatarQueryOptions)?.url
        avatarProvider.setImage(with: gravatarURL, placeholder: placeholder, options: options, completion: nil)
    }

    func refresh(with paletteType: PaletteType) {
        avatarProvider.refresh(with: paletteType)
        backgroundColor = paletteType.palette.background.primary
        Configure(aboutMeLabel).asAboutMe().palette(paletteType)
        Configure(displayNameLabel).asDisplayName().palette(paletteType)
        Configure(personalInfoLabel).asPersonalInfo().palette(paletteType)
        Configure(profileButton).asProfileButton().palette(paletteType)

        aboutMeDashedLabel.dashColor = paletteType.palette.border
        aboutMeDashedLabel.updateDashedBorder()

        accountButtonsStackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
            Configure(button).asAccountButton().palette(paletteType)
        }

        accountButtonsStackView.arrangedSubviews.compactMap { $0 as? RemoteSVGButton }.forEach { view in
            view.refresh(paletteType: paletteType)
        }
        placeholderDisplayer?.refresh(with: placeholderColors, paletteType: paletteType)
    }

    func updateAccountButtons(with model: AccountListModel?) {
        accounts = Array(model?.accountsList.prefix(Constants.maximumAccountsDisplay) ?? [])
        let buttons = accounts.map(createAccountIconView)
        for view in accountButtonsStackView.arrangedSubviews {
            accountButtonsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        buttons.forEach(accountButtonsStackView.addArrangedSubview)
    }

    func createAccountButton(model: AccountModel) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
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

    func createAccountIconView(model: AccountModel) -> UIView {
        let button: UIControl = if UIImage(named: model.shortname) != nil {
            createAccountButton(model: model)
        } else if let iconURL = model.iconURL { // If we have the iconURL try downloading the icon
            createRemoteSVGButton(url: iconURL)
        } else { // This will show the local fallback icon
            createAccountButton(model: model)
        }
        let action = UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.profileView(self, didTapOnAccountButtonWithModel: model)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }

    func createRemoteSVGButton(url: URL) -> RemoteSVGButton {
        let button = RemoteSVGButton(
            iconSize: CGSize(width: Constants.accountIconLength, height: Constants.accountIconLength)
        )
        button.refresh(paletteType: paletteType, shouldReloadURL: false)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Constants.accountIconLength),
            button.heightAnchor.constraint(equalToConstant: Constants.accountIconLength),
        ])
        button.loadIcon(from: url)
        return button
    }

    open func update(with config: ProfileViewConfiguration) {
        paletteType = config.palette
        padding = config.padding
        isLoading = config.isLoading
        avatarActivityIndicatorType = config.avatarActivityIndicatorType
        delegate = config.delegate
        loadAvatar(with: config)
        if config.model != nil || config.summaryModel != nil {
            profileButtonStyle = config.profileButtonStyle
        }
    }

    private func loadAvatar(with config: ProfileViewConfiguration) {
        loadAvatar(
            with: config.avatarID,
            placeholder: config.avatarPlaceholder,
            rating: config.avatarRating,
            defaultAvatarOption: config.defaultAvatarOption,
            options: config.avatarSettingOptions
        )
    }

    private func onProfileButtonPressed(with action: UIAction) {
        let url = profileButtonStyle == .view ? self.model?.profileURL : self.model?.profileEditURL
        self.delegate?.profileView(
            self,
            didTapOnProfileButtonWithStyle: profileButtonStyle,
            profileURL: url
        )
    }

    @objc
    private func avatarTapped() {
        delegate?.profileView(self, didTapOnAvatarWithID: model?.avatarIdentifier)
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
        avatarProvider.setImage(nil)
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
    func profileView(_ view: BaseProfileView, didTapOnAvatarWithID avatarID: AvatarIdentifier?)
}

class DefaultAvatarProvider: AvatarProviding {
    private let avatarLength: CGFloat
    private let avatarImageView: UIImageView
    private let baseView: UIView
    private let skipStyling: Bool
    private(set) var paletteType: PaletteType

    var avatarCornerRadius: CGFloat {
        didSet {
            avatarImageView.layer.cornerRadius = avatarCornerRadius
        }
    }

    var avatarBorderWidth: CGFloat {
        didSet {
            avatarImageView.layer.borderWidth = avatarBorderWidth
        }
    }

    var activityIndicatorType: ActivityIndicatorType = .activity {
        didSet {
            avatarImageView.gravatar.activityIndicatorType = activityIndicatorType
        }
    }

    init(
        baseView: UIView,
        avatarImageView: UIImageView,
        skipStyling: Bool,
        avatarLength: CGFloat,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat = 1,
        paletteType: PaletteType = .system
    ) {
        self.avatarLength = avatarLength
        self.paletteType = paletteType
        self.avatarCornerRadius = cornerRadius ?? avatarLength / 2
        self.avatarBorderWidth = borderWidth
        self.avatarImageView = avatarImageView
        self.baseView = baseView
        self.skipStyling = skipStyling
        configure()
    }

    private func configure() {
        guard !skipStyling else { return }
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.widthAnchor.constraint(equalToConstant: avatarLength).isActive = true
        baseView.heightAnchor.constraint(equalToConstant: avatarLength).isActive = true
        baseView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        baseView.layer.cornerRadius = avatarCornerRadius
        baseView.clipsToBounds = true
    }

    func setImage(with source: URL?, placeholder: UIImage?, options: [ImageSettingOption]?, completion: ((Bool) -> Void)?) {
        avatarImageView.gravatar.setImage(
            with: source,
            placeholder: placeholder,
            options: options
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                if !self.skipStyling {
                    self.baseView.layer.borderColor = self.paletteType.palette.avatar.border.cgColor
                    self.avatarBorderWidth = avatarBorderWidth
                }
                completion?(true)
            default:
                if !self.skipStyling {
                    self.avatarImageView.layer.borderColor = UIColor.clear.cgColor
                }
                completion?(false)
            }
        }
    }

    func setImage(_ image: UIImage?) {
        avatarImageView.image = image
    }

    func refresh(with paletteType: PaletteType) {
        guard !skipStyling else { return }
        self.paletteType = paletteType
        baseView.layer.borderColor = paletteType.palette.avatar.border.cgColor
        baseView.backgroundColor = paletteType.palette.avatar.background
        baseView.overrideUserInterfaceStyle = paletteType.palette.preferredUserInterfaceStyle
    }

    var avatarView: UIView {
        baseView
    }
}
