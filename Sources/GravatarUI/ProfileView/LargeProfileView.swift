import Gravatar
import UIKit

public class LargeProfileView: BaseProfileView {
    private enum Constants {
        static let avatarLength: CGFloat = 132.0
    }

    override public var avatarLength: CGFloat {
        Constants.avatarLength
    }

    private lazy var topStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [avatarImageView, spacer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        return stack
    }()

    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = .DS.Padding.split
        return stack
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        [topStackView, displayNameLabel, personalInfoLabel, aboutMeLabel, bottomStackView].forEach(rootStackView.addArrangedSubview)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: avatarImageView)
        rootStackView.setCustomSpacing(0, after: displayNameLabel)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: aboutMeLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with model: ProfileModel) {
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
        Configure(profileButton).asProfileButton().style(profileButtonStyle).alignment(.trailing).palette(paletteType)
        updateAccountButtons(with: model)
        profileMetadata = model
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        guard let model = config.model else { return }
        update(with: model)
    }
}
