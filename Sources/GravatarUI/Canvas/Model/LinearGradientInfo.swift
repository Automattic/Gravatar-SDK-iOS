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

    func withAlpha(_ alpha: Double) -> LinearGradientInfo {
        let newStops = stops.map { $0.withAlpha(alpha) }
        return LinearGradientInfo(startPoint: startPoint, endPoint: endPoint, stops: newStops)
    }
}

struct Point: Decodable, Hashable {
    let x: Double
    let y: Double
}

struct GradientStop: Decodable, Hashable {
    let color: HexColor
    let position: Double

    func withAlpha(_ newAlpha: Double) -> GradientStop {
        GradientStop(color: HexColor(hex: color.hex, alpha: newAlpha), position: position)
    }
}
