import Foundation

struct LinearGradientInfo: Decodable, Hashable {
    let startPoint: Point
    let endPoint: Point
    let stops: [GradientStop]

    enum CodingKeys: String, CodingKey {
        case startPoint = "start_point"
        case endPoint = "end_point"
        case stops
    }
}

struct Point: Decodable, Hashable {
    let x: Double
    let y: Double
}

struct GradientStop: Decodable, Hashable {
    let color: HexColor
    let position: Double
}
