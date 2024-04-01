import Foundation
import UIKit

extension GravatarWrapper where Component: UILabel {
    public static var defaultPersonalInfo: [PersonalInfoLine] {
        [.init([.jobTitle]),
         .init([.namePronunciation, .separator("・"), .pronouns, .separator("・"), .location])]
    }

    public func buildDisplayName(with model: DisplayNameModel, paletteType: PaletteType = .system) {
        component.text = model.displayName ?? model.fullName ?? model.userName
        component.font = UIFont.DS.title1
        component.textColor = paletteType.palette.foreground.primary
        component.numberOfLines = 0
    }

    public func buildPersonalInfo(
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
        component.text = resultText
        component.font = UIFont.DS.Body.small
        component.textColor = paletteType.palette.foreground.secondary
        component.numberOfLines = lines.count
    }

    public func buildAboutMe(with model: AboutMeModel, paletteType: PaletteType = .system) {
        component.text = model.aboutMe
        component.font = UIFont.DS.Body.small
        component.textColor = paletteType.palette.foreground.primarySlightlyDimmed
        component.numberOfLines = 2
    }
}
