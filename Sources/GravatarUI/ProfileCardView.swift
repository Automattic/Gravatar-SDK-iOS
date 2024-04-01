import Gravatar
import UIKit

public protocol ProfileCardModel: AboutMeModel, DisplayNameModel, PersonalInfoModel, AvatarIdentifierProvider {}
extension UserProfile: ProfileCardModel {}

public class ProfileCardView: UIView {
    enum Constants {
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
        imageView.layer.borderColor = paletteType.palette.avatarBorder.cgColor
        imageView.layer.borderWidth = 1
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
            update(with: paletteType)
        }
    }

    override public init(frame: CGRect) {
        self.paletteType = .system
        super.init(frame: frame)
        addSubview(rootStackView)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: rootStackView.topAnchor),
            leftAnchor.constraint(equalTo: rootStackView.leftAnchor),
            rightAnchor.constraint(equalTo: rootStackView.rightAnchor),
            bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
    }

    public convenience init(frame: CGRect, paletteType: PaletteType) {
        self.init(frame: frame)
        self.paletteType = paletteType
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with model: ProfileCardModel) {
        aboutMeLabel.gravatar.aboutMe.update(with: model, paletteType: paletteType)
        displayNameLabel.gravatar.displayName.update(with: model, paletteType: paletteType)
        personalInfoLabel.gravatar.personalInfo.update(with: model, paletteType: paletteType)
    }

    public func loadAvatar(
        with idProvider: AvatarIdentifierProvider,
        placeholder: UIImage? = nil,
        rating: Rating? = nil,
        preferredSize: CGSize? = nil,
        defaultAvatarOption: DefaultAvatarOption? = nil,
        options: [ImageSettingOption]? = nil,
        completionHandler: ImageSetCompletion? = nil
    ) {
        avatarImageView.gravatar.setImage(
            avatarID: idProvider.avatarIdentifier,
            placeholder: placeholder,
            rating: rating,
            preferredSize: preferredSize ?? CGSize(width: Constants.avatarLength, height: Constants.avatarLength),
            defaultAvatarOption: defaultAvatarOption,
            options: options,
            completionHandler: completionHandler
        )
    }

    func update(with paletteType: PaletteType) {
        avatarImageView.layer.borderColor = paletteType.palette.avatarBorder.cgColor
        backgroundColor = paletteType.palette.background.primary
        aboutMeLabel.gravatar.aboutMe.refreshColor(paletteType: paletteType)
        displayNameLabel.gravatar.displayName.refreshColor(paletteType: paletteType)
        personalInfoLabel.gravatar.personalInfo.refreshColor(paletteType: paletteType)
    }
}
