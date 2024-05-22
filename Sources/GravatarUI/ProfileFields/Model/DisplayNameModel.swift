import Foundation
import Gravatar

public protocol DisplayNameModel {
    var displayName: String { get }
}

extension Profile: DisplayNameModel {}
