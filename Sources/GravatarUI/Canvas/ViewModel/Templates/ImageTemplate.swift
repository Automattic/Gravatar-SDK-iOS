import Combine
import Foundation

struct ImageTemplate: Identifiable {
    let id: String
    let template: CanvasLayers
    let isLoading: Bool

    init(id: String = UUID().uuidString, template: CanvasLayers, isLoading: Bool) {
        self.id = id
        self.template = template
        self.isLoading = isLoading
    }

    func withUpdatingLayer(atIndex index: Int, with kind: CanvasLayer.Kind) -> ImageTemplate {
        guard index >= 0 && index < template.layers.count else {
            return self
        }
        let newLayers = template.layers.enumerated().map { i, layer in
            if i == index {
                layer.copyOverriding(kind: kind)
            } else {
                layer
            }
        }
        return withUpdating(template: CanvasLayers(layers: newLayers))
    }

    func withUpdatingPersonsPreviousLayer(with kind: CanvasLayer.Kind) -> ImageTemplate {
        guard let index = (template.layers.firstIndex { $0.type == .person }) else {
            return self
        }
        let personPrevIndex = index - 1
        return withUpdatingLayer(atIndex: personPrevIndex, with: kind)
    }

    func withUpdating(layerType: LayerType, with kind: CanvasLayer.Kind) -> ImageTemplate {
        let newLayers = template.layers.map { layer in
            if layer.type == layerType {
                layer.copyOverriding(kind: kind)
            } else {
                layer
            }
        }

        return withUpdating(template: CanvasLayers(layers: newLayers))
    }

    func withUpdating(id: String = UUID().uuidString, template newTemplate: CanvasLayers? = nil, isLoading newLoading: Bool? = nil) -> ImageTemplate {
        ImageTemplate(id: id, template: newTemplate ?? template, isLoading: newLoading ?? isLoading)
    }
}
