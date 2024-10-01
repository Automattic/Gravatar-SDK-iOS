import Foundation

/// An error response from the API.
///
public struct ModelError: Codable, Hashable, Sendable {
    /// The error message
    public private(set) var error: String
    /// The error code for the error message
    public private(set) var code: String?

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(error: String, code: String? = nil) {
        self.error = error
        self.code = code
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case error
        case code
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case error
        case code
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(error, forKey: .error)
        try container.encodeIfPresent(code, forKey: .code)
    }

    // Decodable protocol methods

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InternalCodingKeys.self)

        error = try container.decode(String.self, forKey: .error)
        code = try container.decodeIfPresent(String.self, forKey: .code)
    }
}
