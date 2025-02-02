import Foundation

struct CanvasLayers: Decodable, Hashable {
    let layers: [CanvasLayer]

    var personLayer: CanvasLayer? {
        layers.first { $0.type == .person }
    }
}
