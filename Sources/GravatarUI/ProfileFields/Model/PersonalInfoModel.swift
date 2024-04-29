import Foundation
import Gravatar

public struct PersonalInfoLine {
    let buildingBlocks: [PersonalInfoBuildingBlock]
    public init(_ buildingBlocks: [PersonalInfoBuildingBlock]) {
        self.buildingBlocks = buildingBlocks
    }

    func text(from model: PersonalInfoModel) -> String {
        buildingBlocks.compactMap { block in
            block.text(from: model)
        }.joined()
    }
}

public enum PersonalInfoBuildingBlock {
    case jobTitle
    case namePronunciation
    case pronouns
    case location

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
        }
    }
}

public protocol PersonalInfoModel {
    var jobTitle: String? { get }
    var pronunciation: String? { get }
    var pronouns: String? { get }
    var currentLocation: String? { get }
}

extension UserProfile: PersonalInfoModel {}
