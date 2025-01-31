import Foundation

struct LinearGradientInfo: Decodable {
    let startPoint: Point
    let endPoint: Point
    let stops: [GradientStop]

    enum CodingKeys: String, CodingKey {
        case startPoint = "start_point"
        case endPoint = "end_point"
        case stops
    }
}

struct Point: Decodable {
    let x: Double
    let y: Double
}

struct GradientStop: Decodable {
    let color: HexColor
    let position: Double
}
