import Combine
import Foundation
import UIKit

@MainActor
class TemplatesViewModel: ObservableObject {
    static let linearGradients = CanvasLayersParser.decodeLinearGradients()

    @MainActor @Published var templates: [ImageTemplate] = []
    @MainActor @Published var selectedTemplateIndex: Int = 0

    init() {
        addTemplates()
    }

    func addTemplates() {
        templates
            .append(
                contentsOf:
                plainBackgroundDesigns() +
                    fullCircleFrameDesigns() +
                    mediumCircleFrameHalfOpenDesigns() +
                    backgroundCircleBrushDesigns() +
                    backgroundHumanShapeBrushDesigns() +
                    fullCircleFrameSplashOverlayDesigns()
            )
    }

    func plainBackgroundDesigns() -> [ImageTemplate] {
        guard let template = TemplateDesign.plainBackground.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, isLoading: false)

        var colorBackgroundTemplates = HexBackgroundColors.colors[0 ... 3].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }

        var linearBackgroundTemplates = Self.linearGradients[0 ... 3].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func fullCircleFrameDesigns() -> [ImageTemplate] {
        guard let template = TemplateDesign.fullCircleFrame.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, isLoading: false)
        var colorBackgroundTemplates = HexBackgroundColors.colors[4 ... 7].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        var linearBackgroundTemplates = Self.linearGradients[4 ... 7].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func mediumCircleFrameHalfOpenDesigns() -> [ImageTemplate] {
        guard let template = TemplateDesign.mediumCircleFrameHalfOpen.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, isLoading: false)
        var colorBackgroundTemplates = HexBackgroundColors.colors[7 ... 9].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        var linearBackgroundTemplates = Self.linearGradients[7 ... 10].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func backgroundCircleBrushDesigns() -> [ImageTemplate] {
        guard let template = TemplateDesign.backgroundCircleBrush.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, isLoading: false)
        var colorBackgroundTemplates = HexBackgroundColors.colors[8 ... 10].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .color(color))
        }
        var linearBackgroundTemplates = Self.linearGradients[11 ... 14].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func frameCircleBrushHalfOpenDesigns() -> [ImageTemplate] {
        guard let template = TemplateDesign.frameBrush2HalfOpen.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, isLoading: false)
        var colorBackgroundTemplates = HexBackgroundColors.colors[2 ... 4].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        var linearBackgroundTemplates = Self.linearGradients[11 ... 14].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func backgroundHumanShapeBrushDesigns() -> [ImageTemplate] {
        guard let template = TemplateDesign.backgroundHumanShapeBrush.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, isLoading: false)
        var colorBackgroundTemplates1 = HexBackgroundColors.colors[5 ... 6].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        var colorBackgroundTemplates2 = HexBackgroundColors.colors[7 ... 8].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .color(color))
        }
        var linearBackgroundTemplates1 = Self.linearGradients[11 ... 13].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        var linearBackgroundTemplates2 = Self.linearGradients[14 ... 15].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .linearGradient(gradient))
        }

        return colorBackgroundTemplates1 + colorBackgroundTemplates2 + linearBackgroundTemplates1 + linearBackgroundTemplates2
    }

    func fullCircleFrameSplashOverlayDesigns() -> [ImageTemplate] {
        guard let template = TemplateDesign.fullCircleFrameSplashOverlay.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, isLoading: false)
        var colorBackgroundTemplates = HexBackgroundColors.colors[7 ... 9].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        var linearBackgroundTemplates = Self.linearGradients[7 ... 11].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }
}
