import Foundation

// "intrinsic_size": { "ratio": 1 }
struct IntrinsicSize: Decodable, Hashable {
    let ratio: Double

    enum CodingKeys: String, CodingKey {
        case ratio
    }
}

// "size": { "width": 0.75, "height": 0.75 }
struct Size2D: Decodable, Hashable {
    let width: Double
    let height: Double
}
