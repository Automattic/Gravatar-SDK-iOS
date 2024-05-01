import Foundation

struct EmptyProfileModel: ProfileModel {
    let aboutMe: String? = NSLocalizedString("GravatarEmptyProfileAboutMeKey",
                                             value: "Tell the world who you are. Your avatar and bio that follows you across the web.",
                                             comment: "")

    let currentLocation: String? = NSLocalizedString("GravatarEmptyProfileInformationKey",
                                                     value:  "Add your location, pronouns, etc",
                                                     comment: "")

    var displayName: String? = NSLocalizedString("GravatarEmptyProfileDisplayNameKey",
                                                 value: "Your Name",
                                                 comment: "")

    let accountsList: [any AccountModel] = [GravatarAccountModel(accountURL: URL(string: "https://gravatar.com/profile"))]
    let avatarIdentifier: Gravatar.AvatarIdentifier = .hashID("")
    let profileEditURL: URL? = URL(string: "https://gravatar.com/profile")
    let userName: String = "empty"
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
