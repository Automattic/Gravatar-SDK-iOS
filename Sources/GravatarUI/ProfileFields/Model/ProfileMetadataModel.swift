import Foundation
import Gravatar

public protocol ProfileMetadataModel {
    var profileURL: URL? { get }
}

extension UserProfile: ProfileMetadataModel {}
