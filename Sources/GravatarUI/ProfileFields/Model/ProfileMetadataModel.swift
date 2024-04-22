import Foundation
import Gravatar

public protocol ProfileMetadataModel {
    var profileURL: URL? { get }
    var profileEditURL: URL? { get }
}

extension UserProfile: ProfileMetadataModel {
    public var profileEditURL: URL? {
        URL(string: "https://gravatar.com/profile")
    }
}
