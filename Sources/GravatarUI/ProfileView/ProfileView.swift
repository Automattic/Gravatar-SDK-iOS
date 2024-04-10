import Gravatar
import UIKit

public class ProfileView: ProfileComponentView {
    private enum Constants {
        static let avatarLength: CGFloat = 72
    }

    private lazy var topStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, basicInfoStackView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = .DS.Padding.split
        return stack
    }()

    private lazy var basicInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        return stack
    }()

    public init(frame: CGRect, paletteType palette: PaletteType) {
        super.init(frame: frame)

        [topStackView, aboutMeLabel].forEach(rootStackView.addArrangedSubview)

        self.paletteType = palette
        refresh(with: palette)
    }

    public func update(with model: ProfileCardModel) {
        Configure(aboutMeLabel).asAboutMe().content(model).palette(paletteType)
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.smallTitle)
        Configure(personalInfoLabel).asPersonalInfo().content(model).palette(paletteType)
    }
}
