import Gravatar
import UIKit

open class BaseProfileView: UIView, UIContentView {
    enum Constants {
        static let avatarLength: CGFloat = 72
        static let maximumAccountsDisplay = 3
        static let accountIconLength: CGFloat = 32
        static let defaultDisplayNamePlaceholderHeight: CGFloat = 24
        static let placeholderColor: UIColor = .bleachedSilkWhite
        static let loadingAnimationColors: [UIColor] = [placeholderColor, .plasterWhite]
    }

    open var avatarLength: CGFloat {
        Constants.avatarLength
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
    
    public private(set) lazy var aboutMePlaceholderLabel: UILabel = {
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
        var config = UIButton.Configuration.borderless()
        let button = UIButton(configuration: config)
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
    
    /// Provides the activityIndicator to show when `isLoading` is `true` .
    /// Defaults to ``ProfileViewActivityIndicatorProvider``. Set to `nil` in case activity indicator is not wanted.
    public var activityIndicatorProvider: ActivityIndicatorProvider? {
        didSet {
            //addActivityIndicator()
        }
    }
    
    private var activityIndicatorView: UIView?

    public var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            if isLoading {
                startLoadingAnimation()
            }
            else {
                stopLoadingAnimation()
            }
            updatePlaceholderState()
        }
    }
    
    public var shouldShowPlaceholderWhenEmpty: Bool = true
    public var shouldShowPlaceholderWhileLoading: Bool = true

    override public init(frame: CGRect) {
        self.paletteType = .system
        super.init(frame: frame)
        self.padding = Self.defaultPadding
        self.activityIndicatorProvider = ProfileViewActivityIndicatorProvider(colors: [.plasterWhite, .clear])
        commonInit()
    }

    public convenience init(frame: CGRect, paletteType: PaletteType, padding: UIEdgeInsets? = nil) {
        self.init(frame: frame)
        self.paletteType = paletteType
        self.padding = padding ?? Self.defaultPadding
        refresh(with: paletteType)
    }

    func commonInit() {
        addSubview(rootStackView)
        NSLayoutConstraint.activate([
            layoutMarginsGuide.topAnchor.constraint(equalTo: rootStackView.topAnchor),
            layoutMarginsGuide.leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
        //addActivityIndicator()
        refresh(with: paletteType)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updatePlaceholderState()
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

    open func update(with config: ProfileViewConfiguration) {
        paletteType = config.palette
        padding = config.padding
        if let avatarID = config.avatarID {
            loadAvatar(with: avatarID)
        }
        isLoading = config.isLoading
        shouldShowPlaceholderWhileLoading = config.shouldShowPlaceholderWhileLoading
        shouldShowPlaceholderWhenEmpty = config.shouldShowPlaceholderWhenEmpty
    }
    
    // MARK: - Activity Indicator
    
    /*private func addActivityIndicator() {
        if let activityIndicatorView { // Remove previous
            activityIndicatorView.removeFromSuperview()
        }
        guard let activityIndicatorProvider else {
            activityIndicatorView = nil
            return
        }
        let newIndicatorView = activityIndicatorProvider.view
        addSubview(newIndicatorView)
        newIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        newIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        newIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switch activityIndicatorProvider.sizeStrategy(in: self) {
        case .intrinsicSize:
            break
        case .full:
            newIndicatorView.heightAnchor.constraint(equalTo: heightAnchor, constant: 0).isActive = true
            newIndicatorView.widthAnchor.constraint(equalTo: widthAnchor, constant: 0).isActive = true
        case .size(let size):
            newIndicatorView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            newIndicatorView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        bringSubviewToFront(newIndicatorView)
        newIndicatorView.isHidden = true
        activityIndicatorView = newIndicatorView
    }*/
    
    // MARK: - Placeholder handling
    
    var isEmpty: Bool = true {
        didSet {
            updatePlaceholderState()
        }
    }
    
    func shouldShowPlaceholders() -> Bool {
        if shouldShowPlaceholderWhenEmpty && isEmpty {
            return true
        }
        if shouldShowPlaceholderWhileLoading && isLoading {
            return true
        }
        return false
    }
    
    func updatePlaceholderState() {
        if shouldShowPlaceholders() {
            showPlaceholders()
        }
        else {
            hidePlaceholders()
        }
    }
    
    private lazy var placeholderDisplayers: [AnimatingPlaceholderDisplaying] = {
        [
            avatarPlaceholderDisplayer,
            aboutMePlaceholderDisplayer,
            aboutMeSecondLineDisplayer,
            displayNamePlaceholderDisplayer,
            personalInfoPlaceholderDisplayer,
            profileButtonPlaceholderDisplayer,
            accountButtonsPlaceholderDisplayer
        ]
    }()
    
    private lazy var avatarPlaceholderDisplayer: ImageViewPlaceholderDisplayer = {
        ImageViewPlaceholderDisplayer(baseView: avatarImageView, color: Constants.placeholderColor, animationColors: Constants.loadingAnimationColors)
    }()
    
    private lazy var aboutMePlaceholderDisplayer: RectangularPlaceholderDisplayer = {
        RectangularPlaceholderDisplayer(baseView: aboutMeLabel, color: Constants.placeholderColor, cornerRadius: 8, height: 14, widthRatioToParent: 0.8, animationColors: Constants.loadingAnimationColors)
    }()
    
    private lazy var aboutMeSecondLineDisplayer: RectangularPlaceholderDisplayer = {
        RectangularPlaceholderDisplayer(baseView: aboutMePlaceholderLabel, color: Constants.placeholderColor, cornerRadius: 8, height: 14, widthRatioToParent: 0.6, animationColors: Constants.loadingAnimationColors)
    }()
    
    private lazy var displayNamePlaceholderDisplayer: RectangularPlaceholderDisplayer = {
        RectangularPlaceholderDisplayer(baseView: displayNameLabel, color: Constants.placeholderColor, cornerRadius: displayNamePlaceholderHeight / 2, height: displayNamePlaceholderHeight, widthRatioToParent: 0.6, animationColors: Constants.loadingAnimationColors)
    }()

    private lazy var personalInfoPlaceholderDisplayer: RectangularPlaceholderDisplayer = {
        RectangularPlaceholderDisplayer(baseView: personalInfoLabel, color: Constants.placeholderColor, cornerRadius: 8, height: 14, widthRatioToParent: 0.8, animationColors: Constants.loadingAnimationColors)
    }()

    private lazy var profileButtonPlaceholderDisplayer: RectangularPlaceholderDisplayer = {
        RectangularPlaceholderDisplayer(baseView: profileButton, color: Constants.placeholderColor, cornerRadius: 8, height: 16, widthRatioToParent: 0.2, animationColors: Constants.loadingAnimationColors)
    }()
    
    private lazy var accountButtonsPlaceholderDisplayer: AccountButtonsPlaceholderDisplayer = {
        AccountButtonsPlaceholderDisplayer(containerStackView: accountButtonsStackView, color: Constants.placeholderColor, animationColors: Constants.loadingAnimationColors)
    }()
    
    open var displayNamePlaceholderHeight: CGFloat {
        Constants.defaultDisplayNamePlaceholderHeight
    }
    
    open func showPlaceholders() {
        placeholderDisplayers.forEach { $0.show() }
        aboutMePlaceholderLabel.isHidden = false
    }
    
    open func hidePlaceholders() {
        placeholderDisplayers.forEach { $0.hide() }
        aboutMePlaceholderLabel.isHidden = true
    }
    
    func startLoadingAnimation() {
        placeholderDisplayers.forEach { $0.startAnimating() }
    }
    
    func stopLoadingAnimation() {
        placeholderDisplayers.forEach { $0.stopAnimating() }
    }
}
