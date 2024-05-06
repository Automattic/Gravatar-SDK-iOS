import Foundation
import Gravatar

public protocol AvatarIdentifierProvider {
    var avatarIdentifier: AvatarIdentifier? { get }
}

extension UserProfile: AvatarIdentifierProvider {
    public var avatarIdentifier: AvatarIdentifier? {
        .hashID(hash)
    }
}
