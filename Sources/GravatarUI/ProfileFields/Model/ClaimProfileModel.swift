import UIKit

struct ClaimProfileModel: ProfileModel {
    let aboutMe: String? = NSLocalizedString(
        "GravatarEmptyProfileAboutMeKey",
        value: "Tell the world who you are. Your avatar and bio that follows you across the web.",
        comment: ""
    )

    let currentLocation: String? = NSLocalizedString(
        "GravatarEmptyProfileInformationKey",
        value: "Add your location, pronouns, etc",
        comment: ""
    )

    var displayName: String? = NSLocalizedString(
        "GravatarEmptyProfileDisplayNameKey",
        value: "Your Name",
        comment: ""
    )

    let accountsList: [any AccountModel] = [GravatarAccountModel(accountURL: URL(string: "https://gravatar.com/profile"))]
    let avatarIdentifier: Gravatar.AvatarIdentifier? = nil
    let profileEditURL: URL? = URL(string: "https://gravatar.com/profile")
    let userName: String = "claim"
    var fullName: String? {
        displayName
    }

    let jobTitle: String? = nil
    let pronunciation: String? = nil
    let pronouns: String? = nil
    let profileURL: URL? = nil

    init(userName: String? = nil) {
        if let userName {
            self.displayName = userName
        }
    }
}

public protocol ProfileViewClaimProfileConfigurable {
    static func claimProfileConfiguration(userName: String?, palette: PaletteType) -> ProfileViewConfiguration
    func updateWithClaimProfilePrompt(userName: String?)
}

extension ProfileViewClaimProfileConfigurable where Self: BaseProfileView {
    @MainActor
    public func updateWithClaimProfilePrompt(userName: String? = nil) {
        configuration = Self.claimProfileConfiguration(userName: userName, palette: paletteType)
    }
}

extension LargeProfileView: ProfileViewClaimProfileConfigurable {
    public static func claimProfileConfiguration(userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        ProfileViewConfiguration.large(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
    }
}

extension ProfileView: ProfileViewClaimProfileConfigurable {
    public static func claimProfileConfiguration(userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        ProfileViewConfiguration.standard(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
    }
}

extension LargeProfileSummaryView: ProfileViewClaimProfileConfigurable {
    public static func claimProfileConfiguration(userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        ProfileViewConfiguration.largeSummary(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
    }
}

extension ProfileSummaryView: ProfileViewClaimProfileConfigurable {
    public static func claimProfileConfiguration(userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        ProfileViewConfiguration.summary(model: ClaimProfileModel(userName: userName), palette: palette).configureAsClaim()
    }
}

private extension ProfileViewConfiguration {
    func configureAsClaim() -> ProfileViewConfiguration {
        var copy = self
        copy.profileButtonStyle = .create
        copy.avatarPlaceholder = UIImage(named: "empty-profile-avatar")
        return copy
    }
}
