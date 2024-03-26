import Foundation

public protocol IdentifierProvider {
    /// The string that the API expects when specifying a Gravatar type, such as an avatar or profile
    var identifier: String { get }
}
