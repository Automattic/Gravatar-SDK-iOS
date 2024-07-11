import Foundation

/// An interest the user has added to their profile.
///
public struct Interest: Codable, Hashable, Sendable {
    /// The unique identifier for the interest.
    public private(set) var id: Int
    /// The name of the interest.
    public private(set) var name: String

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case name
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case id
        case name
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}
