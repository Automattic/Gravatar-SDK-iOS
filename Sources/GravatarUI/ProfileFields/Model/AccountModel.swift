import Foundation
import Gravatar

public protocol AccountModel {
    var display: String { get }
    var shortname: String { get }
    var iconURL: URL? { get }
    var accountURL: URL? { get }
}

public protocol AccountListModel {
    var accountsList: [AccountModel]? { get }
    var gravatarAccount: AccountModel { get }
}

struct GravatarAccountModel: AccountModel {
    let display: String = "Gravatar"
    let shortname: String = "gravatar"
    let iconURL: URL? = nil
    let accountURL: URL?
}

extension UserProfile.Account: AccountModel {}

extension UserProfile: AccountListModel {
    public var accountsList: [AccountModel]? {
        accounts
    }

    public var gravatarAccount: AccountModel {
        GravatarAccountModel(accountURL: profileURL)
    }
}
