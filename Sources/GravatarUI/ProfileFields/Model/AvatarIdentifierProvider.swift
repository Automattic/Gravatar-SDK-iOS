import Foundation
import Gravatar

public protocol AvatarIdentifierProvider {
    var avatarIdentifier: AvatarIdentifier? { get }
}

extension Profile: AvatarIdentifierProvider {
    public var avatarIdentifier: AvatarIdentifier? {
        .hashID(hash)
    }
}
