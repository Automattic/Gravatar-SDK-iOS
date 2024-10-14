import Foundation

/// The languages the user knows. This is only provided in authenticated API requests.
///
public struct Language: Codable, Hashable, Sendable {
    /// The language code.
    public private(set) var code: String
    /// The language name.
    public private(set) var name: String
    /// Whether the language is the user's primary language.
    public private(set) var isPrimary: Bool
    /// The order of the language in the user's profile.
    public private(set) var order: Int

    init(code: String, name: String, isPrimary: Bool, order: Int) {
        self.code = code
        self.name = name
        self.isPrimary = isPrimary
        self.order = order
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case code
        case name
        case isPrimary = "is_primary"
        case order
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(name, forKey: .name)
        try container.encode(isPrimary, forKey: .isPrimary)
        try container.encode(order, forKey: .order)
    }
}
