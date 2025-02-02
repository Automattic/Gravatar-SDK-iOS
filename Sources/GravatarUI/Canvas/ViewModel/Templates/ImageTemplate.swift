import Foundation
import Combine


struct ImageTemplate: Identifiable {
    let id: String
    let template: CanvasLayers
    let isLoading: Bool

    /* static func new(template: CanvasLayers) -> ImageTemplate {
        ImageTemplate(id: UUID().uuidString, template: template, isLoading: false)
    }*/

    init(id: String, template: CanvasLayers, isLoading: Bool) {
        self.id = id
        self.template = template
        self.isLoading = isLoading
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
    
    func withUpdating(template newTemplate: CanvasLayers? = nil, isLoading newLoading: Bool? = nil) -> ImageTemplate {
        ImageTemplate(id: id, template: newTemplate ?? template, isLoading: newLoading ?? isLoading)
    }
    
}
