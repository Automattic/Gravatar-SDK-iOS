import UIKit

struct ClaimProfileModel: ProfileModel {
    let description: String = NSLocalizedString(
        "GravatarEmptyProfileAboutMeKey",
        value: "Tell the world who you are. Your avatar and bio that follows you across the web.",
        comment: ""
    )

    let location: String = NSLocalizedString(
        "GravatarEmptyProfileInformationKey",
        value: "Add your location, pronouns, etc",
        comment: ""
    )

    var displayName: String = NSLocalizedString(
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

    let jobTitle: String = ""
    let pronunciation: String = ""
    let pronouns: String = ""
    let profileURL: URL? = nil

    init(userName: String? = nil) {
        if let userName {
            self.displayName = userName
        }
    }
}

@MainActor
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
        ProfileViewConfiguration.claimProfile(profileStyle: .large, userName: userName, palette: palette)
    }
}

extension ProfileView: ProfileViewClaimProfileConfigurable {
    public static func claimProfileConfiguration(userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        ProfileViewConfiguration.claimProfile(profileStyle: .standard, userName: userName, palette: palette)
    }
}

extension LargeProfileSummaryView: ProfileViewClaimProfileConfigurable {
    public static func claimProfileConfiguration(userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        ProfileViewConfiguration.claimProfile(profileStyle: .largeSummary, userName: userName, palette: palette)
    }
}

extension ProfileSummaryView: ProfileViewClaimProfileConfigurable {
    public static func claimProfileConfiguration(userName: String? = nil, palette: PaletteType = .system) -> ProfileViewConfiguration {
        ProfileViewConfiguration.claimProfile(profileStyle: .summary, userName: userName, palette: palette)
    }
}
