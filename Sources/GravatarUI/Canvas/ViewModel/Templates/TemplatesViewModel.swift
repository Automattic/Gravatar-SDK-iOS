import Combine
import Foundation
import SwiftUI
import UIKit

@MainActor
class TemplatesViewModel: ObservableObject {
    static let linearGradients = CanvasLayersParser.decodeLinearGradients()

    let originalImage: UIImage
    @MainActor @Published var segmentationResult: SegmentationResult?
    @MainActor @Published var templates: [ImageTemplate] = []
    @MainActor @Published var selectedTemplateIndex: Int = 0
    private var cancellables: Set<AnyCancellable> = []

    init(originalImage: UIImage) {
        self.originalImage = originalImage
        templates.append(contentsOf: originalImageDesigns(image: originalImage))
        listenSegmentationResultChange()
    }

    func listenSegmentationResultChange() {
        $segmentationResult.sink { [weak self] result in
            guard let self else { return }
            if let result {
                self.addTemplatesForMaskedImage(segmentationResult: result)
            } else {
                self.templates.removeAll()
                templates.append(contentsOf: originalImageDesigns(image: originalImage))
            }
        }
        .store(in: &cancellables)
    }

    private func addTemplatesForMaskedImage(segmentationResult: SegmentationResult) {
        withAnimation {
            templates
                .append(
                    contentsOf:
                    plainBackgroundDesigns(segmentationResult: segmentationResult) +
                        fullCircleFrameDesigns(segmentationResult: segmentationResult) +
                        mediumCircleFrameHalfOpenDesigns(segmentationResult: segmentationResult) +
                        backgroundCircleBrushDesigns(segmentationResult: segmentationResult) +
                        frameCircleBrushHalfOpenDesigns(segmentationResult: segmentationResult) +
                        backgroundHumanShapeBrushDesigns(segmentationResult: segmentationResult) +
                        fullCircleFrameSplashOverlayDesigns(segmentationResult: segmentationResult)
                )
        }
    }

    func originalImageDesigns(image: UIImage) -> [ImageTemplate] {
        guard let template = TemplateDesign.plainBackground.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(image: image, template: template, isLoading: false)
        let newTemplate = imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(HexColor(hex: "000000")))
        return [newTemplate]
    }

    func plainBackgroundDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.plainBackground.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)

        let colorBackgroundTemplates = HexBackgroundColors.colors[0 ... 3].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }

        let linearBackgroundTemplates = Self.linearGradients[0 ... 3].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func fullCircleFrameDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.fullCircleFrame.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[4 ... 7].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[4 ... 7].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func mediumCircleFrameHalfOpenDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.mediumCircleFrameHalfOpen.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[7 ... 9].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[7 ... 10].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func backgroundCircleBrushDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.backgroundCircleBrush.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[8 ... 10].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[11 ... 14].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func frameCircleBrushHalfOpenDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.frameBrush2HalfOpen.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[2 ... 4].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[11 ... 14].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func backgroundHumanShapeBrushDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.backgroundHumanShapeBrush.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates1 = HexBackgroundColors.colors[5 ... 6].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let colorBackgroundTemplates2 = HexBackgroundColors.colors[7 ... 8].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .color(color))
        }
        let linearBackgroundTemplates1 = Self.linearGradients[11 ... 14].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        let linearBackgroundTemplates2 = Self.linearGradients[12 ... 15].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 1, with: .linearGradient(gradient))
        }

        return colorBackgroundTemplates1 + colorBackgroundTemplates2 + linearBackgroundTemplates1 + linearBackgroundTemplates2
    }

    func fullCircleFrameSplashOverlayDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.fullCircleFrameSplashOverlay.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[7 ... 9].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[7 ... 11].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }
}
