import UIKit

public struct PersonalInfoBuilder {
    public static var defaultPersonalInfo: [PersonalInfoLine] {
        [.init([.jobTitle]),
         .init([.namePronunciation, .defaultSeparator, .pronouns, .defaultSeparator, .location])]
    }

    var label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    public func content(
        _ model: PersonalInfoModel,
        lines: [PersonalInfoLine] = Self.defaultPersonalInfo
    ) -> PersonalInfoBuilder {
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
        return self
    }

    @discardableResult
    public func palette(_ paletteType: PaletteType) -> PersonalInfoBuilder {
        label.textColor = paletteType.palette.foreground.secondary
        return self
    }
}
