import Foundation
import Gravatar

public protocol DisplayNameModel {
    var displayName: String? { get }
    var fullName: String? { get }
    var userName: String { get }
}

extension UserProfile: DisplayNameModel {
    public var userName: String {
        preferredUsername
    }

    public var fullName: String? {
        name?.formatted
    }
}
