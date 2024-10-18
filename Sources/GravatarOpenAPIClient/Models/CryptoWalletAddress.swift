import Foundation

/// A crypto currency wallet address the user accepts.
///
public struct CryptoWalletAddress: Codable, Hashable, Sendable {
    /// The label for the crypto currency.
    public private(set) var label: String
    /// The wallet address for the crypto currency.
    public private(set) var address: String

    init(label: String, address: String) {
        self.label = label
        self.address = address
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case label
        case address
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(address, forKey: .address)
    }
}
