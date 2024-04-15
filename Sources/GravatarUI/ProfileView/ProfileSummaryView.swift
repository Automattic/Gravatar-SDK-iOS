import Gravatar
import UIKit

public class ProfileSummaryView: ProfileComponentView {
    var model: ProfileSummaryModel?

    private lazy var basicInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [displayNameLabel, personalInfoLabel, profileButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()

    public init(frame: CGRect, paletteType palette: PaletteType) {
        super.init(frame: frame)

        rootStackView.axis = .horizontal
        rootStackView.alignment = .top

        [avatarImageView, basicInfoStackView].forEach(rootStackView.addArrangedSubview)

        layoutMargins = UIEdgeInsets(
            top: .DS.Padding.split,
            left: .DS.Padding.medium,
            bottom: .DS.Padding.split,
            right: .DS.Padding.medium
        )

        self.paletteType = palette
        refresh(with: palette)
    }

    public func update(with model: ProfileSummaryModel) {
        self.model = model
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType).font(.DS.smallTitle)
        Configure(personalInfoLabel).asPersonalInfo().content(model, lines: [.init([.location])]).palette(paletteType)
        Configure(profileButton).asProfileButton().style(.view).palette(paletteType)
    }
}
