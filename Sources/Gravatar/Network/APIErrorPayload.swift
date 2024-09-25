import Foundation

/// Error payload for the REST API calls.
public protocol APIErrorPayload: Sendable {
    /// A business error code that identifies this error. (This is not the HTTP status code.)
    var code: String { get }
    /// Error message that comes from the REST API.
    var message: String? { get }
}

extension ModelError: APIErrorPayload {
    public var message: String? {
        error
    }
}
