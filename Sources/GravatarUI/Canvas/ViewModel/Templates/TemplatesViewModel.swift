import Foundation
import Combine

@MainActor
class TemplatesViewModel: ObservableObject {

    static let allTemplates = CanvasLayersParser.decodeAllTemplates()
    static let linearGradients = CanvasLayersParser.decodeLinearGradients()
    
    @MainActor @Published var templates: [ImageTemplate] = []
    
    init() {
        
    }
}
