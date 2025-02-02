import Foundation

enum CanvasLayersParser {
    enum Templates {
        static let all = [
            "avatar-medium-circle-frame-half-open",
        ]
    }

    static func decodeAllTemplates() -> [CanvasLayers] {
        Templates.all.compactMap {
            do {
                return try decodeTemplate(name: $0)
            } catch {
                print("error: \(error)")
            }
            return nil
        }
    }
    
    static func decodeLinearGradients() -> [LinearGradientInfo] {
        do {
            let data = try dataFromJSON(fileName: "gradient-list")
            let result = try JSONDecoder().decode([LinearGradientInfo].self, from: data)
            return result
        }
        catch {
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
