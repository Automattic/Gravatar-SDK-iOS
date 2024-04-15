import Gravatar
import UIKit

public typealias ProfileCardModel = AboutMeModel & AccountListModel & AvatarIdentifierProvider & DisplayNameModel & PersonalInfoModel

public class LargeProfileView: UIView {
    private enum Constants {
        static let avatarLength: CGFloat = 132.0
    }

    public private(set) lazy var rootStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, displayNameLabel, personalInfoLabel, aboutMeLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = .DS.Padding.single
        stack.setCustomSpacing(.DS.Padding.double, after: avatarImageView)
        stack.setCustomSpacing(0, after: displayNameLabel)
        stack.alignment = .leading
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

    public var paletteType: PaletteType {
        didSet {
            refresh(with: paletteType)
        }
    }

    public let containerLayoutGuide = UILayoutGuide()

    override public init(frame: CGRect) {
        self.paletteType = .system
        super.init(frame: frame)
        addSubview(rootStackView)
        addLayoutGuide(containerLayoutGuide)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerLayoutGuide.topAnchor),
            leadingAnchor.constraint(equalTo: containerLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerLayoutGuide.trailingAnchor),
            bottomAnchor.constraint(equalTo: containerLayoutGuide.bottomAnchor),
            topAnchor.constraint(equalTo: rootStackView.topAnchor),
            leadingAnchor.constraint(equalTo: rootStackView.leadingAnchor),
            trailingAnchor.constraint(equalTo: rootStackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
    }

    public convenience init(frame: CGRect, paletteType: PaletteType) {
        self.init(frame: frame)
        self.paletteType = paletteType
        refresh(with: paletteType)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with model: ProfileCardModel) {
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
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
    }
}
