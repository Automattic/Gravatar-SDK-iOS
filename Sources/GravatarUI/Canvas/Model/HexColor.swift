import Foundation

/// Represents a color specification with a hex string and alpha channel
struct HexColor: Decodable {
    let hex: String
    let alpha: Double
}
