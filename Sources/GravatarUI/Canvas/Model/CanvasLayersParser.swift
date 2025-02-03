import Foundation

enum TemplateDesign: String, CaseIterable {
    case plainBackground = "01.plain-background"
    case fullCircleFrame = "02.full-circle-frame"
    case mediumCircleFrameHalfOpen = "03.medium-circle-frame-half-open"
    case backgroundCircleBrush = "04.background-circle-brush"
    case frameCircleBrushHalfOpen = "05.frame-circle-brush-half-open"
    case frameBrush2HalfOpen = "06.frame-brush-2-half-open"
    case backgroundHumanShapeBrush = "07.background-human-shape-brush"
    case fullCircleFrameSplashOverlay = "08.full-circle-frame-splash-overlay"
    case mediumRoundedRectFrameHalfOpen = "09.medium-rounded-rect-frame-half-open"
    case fullCircleFrameDoubleBackgrounds = "10.full-circle-frame-double-bg-layers"

    static let dict: [TemplateDesign: CanvasLayers] = {
        var result: [TemplateDesign: CanvasLayers] = [:]
        for template in TemplateDesign.allCases {
            do {
                let layers = try CanvasLayersParser.decodeTemplate(name: template.rawValue)
                result[template] = layers
            } catch {
                print("error: \(error)")
            }
        }
        return result
    }()

    func getLayers() -> CanvasLayers? {
        TemplateDesign.dict[self]
    }
}

enum CanvasLayersParser {
    static func decodeLinearGradients() -> [LinearGradientInfo] {
        do {
            let data = try dataFromJSON(fileName: "gradient-list")
            let result = try JSONDecoder().decode([LinearGradientInfo].self, from: data)
            return result
        } catch {
            print("error: \(error)")
        }
        return []
    }

    static func decodeTemplate(name: String) throws -> CanvasLayers {
        let data = try dataFromJSON(fileName: name)
        return try decodeTemplateData(data)
    }

    static func dataFromJSON(fileName name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw NSError(domain: "CanvasLayersParser", code: 100, userInfo: nil)
        }
        let data = try Data(contentsOf: url)
        return data
    }

    static func decodeTemplateData(_ data: Data) throws -> CanvasLayers {
        let object = try JSONDecoder().decode(CanvasLayers.self, from: data)
        return object
    }
}
