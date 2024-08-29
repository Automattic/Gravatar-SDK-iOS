import UIKit

struct ClaimProfileModel: ProfileModel {
    let description: String = NSLocalizedString(
        "ClaimProfile.Label.AboutMe",
        value: "Tell the world who you are. Your avatar and bio that follows you across the web.",
        comment: "Text on a sample Gravatar profile, appearing in the place where a Gravatar profile would display your short biography."
    )

    let location: String = NSLocalizedString(
        "ClaimProfile.Label.Location",
        value: "Add your location, pronouns, etc",
        comment: "Text on a sample Gravatar profile, appearing in the place where a Gravatar profile would display information like location, your preferred pronouns, etc."
    )

    var displayName: String = NSLocalizedString(
        "ClaimProfile.Label.DisplayName",
        value: "Your Name",
        comment: "Text on a sample Gravatar profile, appearing in the place where your name would normally appear on your Gravatar profile after you claim it."
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
