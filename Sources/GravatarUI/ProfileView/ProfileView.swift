import Gravatar
import UIKit

public class ProfileView: ProfileComponentView {
    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, basicInfoStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = .DS.Padding.split
        return stack
    }()

    private lazy var bottomStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountButtonsStackView, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = .DS.Padding.split
        return stack
    }()

    private lazy var basicInfoStackView: UIStackView = {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel, spacer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .equalCentering
        return stack
    }()

    public init(frame: CGRect, paletteType palette: PaletteType) {
        super.init(frame: frame)

        [topStackView, aboutMeLabel, bottomStackView].forEach(rootStackView.addArrangedSubview)

        self.paletteType = palette
        refresh(with: palette)

        layoutMargins = UIEdgeInsets(
            top: .DS.Padding.medium,
            left: .DS.Padding.medium,
            bottom: .DS.Padding.single,
            right: .DS.Padding.medium
        )
    }

    public func update(with model: ProfileCardModel) {
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.smallTitle)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
        Configure(profileButton).asProfileButton().style(.view).alignment(.trailing).palette(paletteType)

        updateAccountButtons(with: model)
    }
}
