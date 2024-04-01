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

    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(rootStackView)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: rootStackView.topAnchor),
            leftAnchor.constraint(equalTo: rootStackView.leftAnchor),
            rightAnchor.constraint(equalTo: rootStackView.rightAnchor),
            bottomAnchor.constraint(equalTo: rootStackView.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with model: ProfileCardModel, paletteType: PaletteType = .system) {
        aboutMeLabel.gravatar.buildAboutMe(with: model, paletteType: paletteType)
        displayNameLabel.gravatar.buildDisplayName(with: model, paletteType: paletteType)
        personalInfoLabel.gravatar.buildPersonalInfo(with: model, paletteType: paletteType)
        backgroundColor = paletteType.palette.background.primary
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
}
