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
    var selectedTemplate: ImageTemplate? {
        guard selectedTemplateIndex >= 0, selectedTemplateIndex < templates.count else { return nil }
        return templates[selectedTemplateIndex]
    }

    init(originalImage: UIImage) {
        self.originalImage = originalImage
        templates.append(contentsOf: originalImageDesigns(image: originalImage))
        listenSegmentationResultChange()
    }

    func listenSegmentationResultChange() {
        $segmentationResult.sink { [weak self] result in
            guard let self else { return }
            var newTemplates: [ImageTemplate] = []
            if let result {
                newTemplates.append(contentsOf: self.originalImageDesigns(image: self.originalImage))
                newTemplates.append(contentsOf: self.templatesForMaskedImage(segmentationResult: result))
            } else {
                newTemplates.append(contentsOf: self.originalImageDesigns(image: self.originalImage))
            }
            withAnimation {
                self.templates = newTemplates
                self.selectedTemplateIndex = self.selectedTemplateIndex // trigger update because the image has changed
            }
        }
        .store(in: &cancellables)
    }

    private func templatesForMaskedImage(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        let templates =
            plainBackgroundDesigns(segmentationResult: segmentationResult) +
            fullCircleFrameDesigns(segmentationResult: segmentationResult) +
            //  fullCircleFrameImageBackgroundDesigns(segmentationResult: segmentationResult) +
            mediumCircleFrameHalfOpenDesigns(segmentationResult: segmentationResult) +
            mediumRoundedRectFrameHalfOpenDesigns(segmentationResult: segmentationResult) +
            backgroundCircleBrushDesigns(segmentationResult: segmentationResult) +
            frameCircleBrushHalfOpenDesigns(segmentationResult: segmentationResult) +
            frameBrush2HalfOpenDesigns(segmentationResult: segmentationResult) +
            //   backgroundHumanShapeBrushDesigns(segmentationResult: segmentationResult) +
            fullCircleFrameSplashOverlayDesigns(segmentationResult: segmentationResult)
        return templates
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

    func fullCircleFrameImageBackgroundDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template1 = TemplateDesign.fullCircleFrame.getLayers() else { return [] }
        guard let template2 = TemplateDesign.fullCircleFrameDoubleBackgrounds.getLayers() else { return [] }
        let images = ["bg01", "bg02", "bg03", "bg04", "bg05", "bg06"]
        let imageTemplate1 = ImageTemplate(template: template1, segmentationResult: segmentationResult)
        let imageTemplate2 = ImageTemplate(template: template2, segmentationResult: segmentationResult)

        var result: [ImageTemplate] = []
        for (index, name) in images.enumerated() {
            let templateWithImage1 = imageTemplate1.withUpdatingLayer(atIndex: 0, with: .localImage(name))
            result.append(templateWithImage1)

            let templateWithImage2 = imageTemplate2.withUpdatingLayer(atIndex: 0, with: .localImage(name))
            result.append(templateWithImage2)
            let index = (5 + index) % (Self.linearGradients.count)
            let gradient = Self.linearGradients[index].withAlpha(0.2)
            result.append(templateWithImage2.withUpdatingLayer(atIndex: 1, with: .linearGradient(gradient)))
        }

        return result
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

    func mediumRoundedRectFrameHalfOpenDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.mediumRoundedRectFrameHalfOpen.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[6 ... 8].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[10 ... 13].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func backgroundCircleBrushDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.backgroundCircleBrush.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[8 ... 10].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[11 ... 14].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func frameCircleBrushHalfOpenDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.frameCircleBrushHalfOpen.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[2 ... 4].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[11 ... 14].map { gradient in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .linearGradient(gradient))
        }
        return colorBackgroundTemplates + linearBackgroundTemplates
    }

    func frameBrush2HalfOpenDesigns(segmentationResult: SegmentationResult) -> [ImageTemplate] {
        guard let template = TemplateDesign.frameBrush2HalfOpen.getLayers() else { return [] }
        let imageTemplate = ImageTemplate(template: template, segmentationResult: segmentationResult)
        let colorBackgroundTemplates = HexBackgroundColors.colors[6 ... 9].map { color in
            imageTemplate.withUpdatingLayer(atIndex: 0, with: .color(color))
        }
        let linearBackgroundTemplates = Self.linearGradients[9 ... 15].map { gradient in
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
