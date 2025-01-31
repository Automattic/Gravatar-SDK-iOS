import Foundation

// "size_from_aspect_ratio": { "width": 1, "aspect_ratio": 1 }
struct SizeFromAspectRatio: Decodable {
    let width: Double
    let aspectRatio: Double

    enum CodingKeys: String, CodingKey {
        case width
        case aspectRatio = "aspect_ratio"
    }
}

// "size": { "width": 0.75, "height": 0.75 }
struct Size2D: Decodable {
    let width: Double
    let height: Double
}
