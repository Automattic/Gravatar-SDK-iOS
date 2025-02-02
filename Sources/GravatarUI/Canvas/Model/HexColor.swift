import Foundation

/// Represents a color specification with a hex string and alpha channel
struct HexColor: Decodable, Hashable {
    let hex: String
    let alpha: Double

    init(hex: String, alpha: Double = 1) {
        self.hex = hex
        self.alpha = alpha
    }
}
