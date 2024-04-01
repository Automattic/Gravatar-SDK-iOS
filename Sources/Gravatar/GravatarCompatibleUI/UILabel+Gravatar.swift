import Foundation
import UIKit

extension GravatarWrapper where Component: UILabel {
    public var displayName: DisplayNameField {
        DisplayNameField(label: component)
    }

    public var personalInfo: PersonalInfoField {
        PersonalInfoField(label: component)
    }

    public var aboutMe: AboutMeField {
        AboutMeField(label: component)
    }
}

public protocol PaletteRefreshable {
    func refreshColor(paletteType: PaletteType)
}

public struct DisplayNameField: PaletteRefreshable {
    var label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    public func update(with model: DisplayNameModel, paletteType: PaletteType) {
        label.text = model.displayName ?? model.fullName ?? model.userName
        label.font = UIFont.DS.title1
        label.numberOfLines = 0
        refreshColor(paletteType: paletteType)
    }

    public func refreshColor(paletteType: PaletteType) {
        label.textColor = paletteType.palette.foreground.primary
    }
}

public struct PersonalInfoField: PaletteRefreshable {
    public static var defaultPersonalInfo: [PersonalInfoLine] {
        [.init([.jobTitle]),
         .init([.namePronunciation, .separator("・"), .pronouns, .separator("・"), .location])]
    }

    var label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    public func update(
        with model: PersonalInfoModel,
        lines: [PersonalInfoLine] = Self.defaultPersonalInfo,
        paletteType: PaletteType = .system
    ) {
        var resultText = ""
        for line in lines {
            let text = line.text(from: model)
            if !resultText.isEmpty && !resultText.hasSuffix("\n") {
                resultText.append("\n")
            }
            resultText.append(text)
        }
        label.text = resultText
        label.font = UIFont.DS.Body.small
        label.numberOfLines = lines.count
        refreshColor(paletteType: paletteType)
    }

    public func refreshColor(paletteType: PaletteType) {
        label.textColor = paletteType.palette.foreground.secondary
    }
}

public struct AboutMeField: PaletteRefreshable {
    var label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    public func update(with model: AboutMeModel, paletteType: PaletteType) {
        label.text = model.aboutMe
        label.font = UIFont.DS.Body.small
        label.numberOfLines = 2
        refreshColor(paletteType: paletteType)
    }

    public func refreshColor(paletteType: PaletteType) {
        label.textColor = paletteType.palette.foreground.primarySlightlyDimmed
    }
}
