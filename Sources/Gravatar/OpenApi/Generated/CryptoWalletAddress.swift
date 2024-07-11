import Foundation

/// A crypto currency wallet address the user accepts.
///
public struct CryptoWalletAddress: Codable, Hashable, Sendable {
    /// The label for the crypto currency.
    public private(set) var label: String
    /// The wallet address for the crypto currency.
    public private(set) var address: String

    @available(*, deprecated, message: "init will become internal on the next release")
    public init(label: String, address: String) {
        self.label = label
        self.address = address
    }

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case label
        case address
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case label
        case address
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(address, forKey: .address)
    }
}
