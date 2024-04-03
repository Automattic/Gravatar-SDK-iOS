import UIKit

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
        label.font = .DS.Body.small
        label.numberOfLines = lines.count
        refresh(with: paletteType)
    }

    public func refresh(with paletteType: PaletteType) {
        label.textColor = paletteType.palette.foreground.secondary
    }
}

