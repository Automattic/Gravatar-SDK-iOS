import Foundation
import Gravatar

public struct PersonalInfoLine {
    let buildingBlocks: [PersonalInfoBuildingBlock]
    public init(_ buildingBlocks: [PersonalInfoBuildingBlock]) {
        self.buildingBlocks = buildingBlocks
    }

    func text(from model: PersonalInfoModel) -> String {
        var string = ""
        for block in buildingBlocks {
            string += block.text(from: model) ?? ""
        }
        return string
    }
}

public enum PersonalInfoBuildingBlock {
    case jobTitle
    case namePronunciation
    case pronouns
    case location
    case separator(String)

    func text(from model: PersonalInfoModel) -> String? {
        switch self {
        case .jobTitle:
            model.jobTitle
        case .namePronunciation:
            model.pronunciation
        case .pronouns:
            model.pronouns
        case .location:
            model.currentLocation
        case .separator(let string):
            string
        }
    }
    
    static var defaultSeparator: PersonalInfoBuildingBlock {
        .separator("・")
    }
}

public protocol PersonalInfoModel {
    var jobTitle: String? { get }
    var pronunciation: String? { get }
    var pronouns: String? { get }
    var currentLocation: String? { get }
}
