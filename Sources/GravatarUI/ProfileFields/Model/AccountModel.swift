import Foundation
import Gravatar

public protocol AccountModel {
    var serviceLabel: String { get }
    var shortname: String { get }
    var iconURL: URL? { get }
    var accountURL: URL? { get }
}

public protocol AccountListModel {
    var accountsList: [AccountModel] { get }
}

struct GravatarAccountModel: AccountModel {
    let serviceLabel: String = "Gravatar"
    let shortname: String = "gravatar"
    let iconURL: URL? = nil
    let accountURL: URL?
}

extension VerifiedAccount: AccountModel {
    public var shortname: String {
        serviceLabel.lowercased()
    }

    public var iconURL: URL? {
        URL(string: serviceIcon)
    }

    public var accountURL: URL? {
        URL(string: url)
    }
}

extension Profile: AccountListModel {
    public var accountsList: [AccountModel] {
        [gravatarAccount] + verifiedAccounts
    }

    var gravatarAccount: AccountModel {
        GravatarAccountModel(accountURL: URL(string: profileUrl))
    }
}
