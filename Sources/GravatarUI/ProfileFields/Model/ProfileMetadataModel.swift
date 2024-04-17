import Gravatar
import Foundation

public protocol ProfileMetadataModel {
    var profileURL: URL? { get }
}

extension UserProfile: ProfileMetadataModel { }
