import Gravatar
import UIKit

/// This class is used as a base class to create different profile view design styles.
/// > This class is meant to be used as an abstract class. Do not use it on its own.
///
/// You can subclass BaseProfileView to create your own Profile View designs.
open class BaseProfileView: UIView, UIContentView {
    enum Constants {
        static let avatarLength: CGFloat = 72
        static let maximumAccountsDisplay = 4
        static let accountIconLength: CGFloat = 32
        static let defaultDisplayNamePlaceholderHeight: CGFloat = 24
    }

    public enum PlaceholderColorPolicy {
        /// Gets the placeholder colors from the current palette.
        case currentPalette
        /// Custom colors. You can also pass predefined colors from any ``Palette``. Example:  `PaletteType.light.palette.placeholder`.
        case custom(PlaceholderColors)
    }

    /// The diameter of the circular avatar image.
    open class var avatarLength: CGFloat {
        Constants.avatarLength
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
    /// Defaults to `ProfilePlaceholderActivityIndicator`.
    public var activityIndicator: (any ProfileActivityIndicator)?

    /// Avatar's activity indicator to show while downloading an image.
    public var avatarActivityIndicatorType: ActivityIndicatorType = .activity {
        didSet {
            if let provider = avatarProvider as? DefaultAvatarProvider {
                provider.activityIndicatorType = avatarActivityIndicatorType
            }
        }
    }

    /// Whether the view is in loading state.
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

    /// The style for the profile view action button.
    /// > Avoid setting `.create` manually. Instead, create a configuration using `ProfileView.claimProfileConfiguration()` and set it to the view.
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

    /// The object that acts as the delegate for the profile view.
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

    /// Empty stack view added to the view's hierarchy.
    /// Use this stack as a base to create your own Profile View design.
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

    /// The view which displays the profile's avatar image.
    public var avatarImageView: UIImageView? {
        avatarType.imageView
    }

    let aboutMeDashedLabel: DashedLabel = {
        let label = DashedLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    /// The lable which displays the profile description text.
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

    /// The label which displays the profile name text.
    public private(set) lazy var displayNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    /// The label which displays the profile personal information text,
    /// such as location, pronouns, etc...
    public private(set) lazy var personalInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    /// The profile action button.
    public lazy var profileButton: UIButton = {
        let button = UIButton(configuration: .borderless())
        let action = UIAction { [weak self] action in
            self?.onProfileButtonPressed(with: action)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()

    /// A stack which holds all accounts buttons, such as Gravatar, WordPress, Tumblr, etc...
    public let accountButtonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = .DS.Padding.half
        stack.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return stack
    }()

    /// The palette used to set the profile view colors.
    public var paletteType: PaletteType {
        didSet {
            refresh(with: paletteType)
        }
    }

    /// Creates an instance of BaseProfileView. **Do not** create an instance directly.
    /// >  This class is intended as an abstract class. You can subclass BaseProfileView, and call this init method as `super.init(...)`. You should override `arrangeSubviews()` to put your views in the `rootStackView`.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view, measured in points.
    ///   - paletteType: The palette used to apply colors to the view. Defaults to `.system`.
    ///   - profileButtonStyle: The profile action button style. Defaults to `.view`
    ///   - avatarType: The avatar view type to be used to display the avatar image. Defaults to a `UIImageView`.
    ///   - padding: The space around the profile view content. Defaults to a standard padding.
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

    /// Loads an avatar to be displayed in the avatar view.
    /// - Parameters:
    ///   - avatarIdentifier: The identifier of the avatar to be loaded.
    ///   - placeholder: An image which will be temporarily displayed while the avatar loads.
    ///   - rating: The maximum avatar rating for the avatar to be displayed. See ``Rating``.
    ///   - defaultAvatarOption: The avatar which the server will return in case that the avatar with the given id is not found, or if the avatar rating is
    /// higher than the specified.
    ///   - options: Options to use when fetching a Gravatar profile image and setting it to the avatar image view.
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
        Task {
            try await avatarProvider.setImage(with: gravatarURL, placeholder: placeholder, options: options)
        }
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

    /// Updates the profile view content and palette color with the given configuration.
    /// - Parameter config: A profile view configuration with the desired content and styles to be displayed.
    open func update(with config: ProfileViewConfiguration) {
        paletteType = config.palette
        padding = config.padding
        isLoading = config.isLoading
        avatarActivityIndicatorType = config.avatarConfiguration.activityIndicatorType
        delegate = config.delegate
        loadAvatar(with: config)
        if config.model != nil || config.summaryModel != nil {
            profileButtonStyle = config.profileButtonStyle
        }
    }

    private func loadAvatar(with config: ProfileViewConfiguration) {
        loadAvatar(
            with: config.avatarID,
            placeholder: config.avatarConfiguration.placeholder,
            rating: config.avatarConfiguration.rating,
            defaultAvatarOption: config.avatarConfiguration.defaultAvatarOption,
            options: config.avatarConfiguration.settingOptions
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

/// Methods for managing actions on the profile view.
public protocol ProfileViewDelegate: NSObjectProtocol {
    /// Tells the delegate that the profile action button of the view has been tapped.
    ///
    /// The `profileURL` contains a url which corresponds to the button intended action declared by the button style.
    /// > The recommended action for this delegate method is to present this URL in a `SFSafariViewController`.
    /// - Parameters:
    ///   - view: The profile view informing about the tap.
    ///   - style: The current profile action button style.
    ///   - profileURL: A possible URL to be presented to the user
    func profileView(_ view: BaseProfileView, didTapOnProfileButtonWithStyle style: ProfileButtonStyle, profileURL: URL?)
    /// Tells the delegate one of the profile associated accounts button has been tapped.
    ///
    /// The `accountModel` contains information about the tapped account including a URL to it.
    /// > The recommended action for this delegate method is to present this URL in a `SFSafariViewController`.
    /// - Parameters:
    ///   - view: The profile view informing about the tap.
    ///   - accountModel: Information about the associated account which was tapped.
    func profileView(_ view: BaseProfileView, didTapOnAccountButtonWithModel accountModel: AccountModel)
    /// Tells the delegate that the profile avatar view has been tapped.
    /// - Parameters:
    ///   - view: The profile view informing about the tap.
    ///   - avatarID: The ID of the avatar tapped.
    func profileView(_ view: BaseProfileView, didTapOnAvatarWithID avatarID: AvatarIdentifier?)
}
