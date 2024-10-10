import Foundation

/// An error response from the API.
///
public struct ModelError: Codable, Hashable, Sendable {
    /// The error message
    public private(set) var error: String
    /// The error code for the error message
    public private(set) var code: String?

    init(error: String, code: String? = nil) {
        self.error = error
        self.code = code
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case error
        case code
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(error, forKey: .error)
        try container.encodeIfPresent(code, forKey: .code)
    }
}
