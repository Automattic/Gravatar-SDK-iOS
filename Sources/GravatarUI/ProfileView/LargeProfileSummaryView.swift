import Gravatar
import UIKit

public class LargeProfileSummaryView: BaseProfileView {
    private enum Constants {
        static let avatarLength: CGFloat = 132.0
        static let displayNamePlaceholderHeight: CGFloat = 32
    }

    public static var personalInfoLines: [PersonalInfoLine] {
        [
            .init([.namePronunciation, .pronouns, .location]),
        ]
    }

    override public var avatarLength: CGFloat {
        Constants.avatarLength
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        [avatarImageView, displayNameLabel, personalInfoLabel, profileButton].forEach(rootStackView.addArrangedSubview)
        rootStackView.setCustomSpacing(.DS.Padding.double, after: avatarImageView)
        rootStackView.setCustomSpacing(0, after: displayNameLabel)
        rootStackView.setCustomSpacing(0, after: personalInfoLabel)
        rootStackView.alignment = .center
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with model: ProfileSummaryModel) {
        Configure(displayNameLabel).asDisplayName().content(model).palette(paletteType)
        Configure(personalInfoLabel).asPersonalInfo().content(model, lines: Self.personalInfoLines).palette(paletteType)
        displayNameLabel.textAlignment = .center
        personalInfoLabel.textAlignment = .center
        Configure(profileButton).asProfileButton().style(profileButtonStyle).palette(paletteType)
        profileMetadata = model
    }

    override public func update(with config: ProfileViewConfiguration) {
        super.update(with: config)
        guard let model = config.summaryModel else { return }
        update(with: model)
    }

    override public var displayNamePlaceholderHeight: CGFloat {
        Constants.displayNamePlaceholderHeight
    }
}
