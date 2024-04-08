import UIKit

public struct PersonalInfoBuilder {
    public static var defaultPersonalInfo: [PersonalInfoLine] {
        [
            .init([.jobTitle]),
            .init([.namePronunciation, .defaultSeparator, .pronouns, .defaultSeparator, .location])
        ]
    }

    let label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    @discardableResult
    public func content(
        _ model: PersonalInfoModel,
        lines: [PersonalInfoLine] = Self.defaultPersonalInfo
    ) -> PersonalInfoBuilder {
        var resultText = ""
        var previousLine = ""
        for line in lines {
            let text = line.text(from: model)
            if !previousLine.isEmpty && !text.isEmpty {
                resultText.append("\n")
            }
            resultText.append(text)
            previousLine = text
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

    @discardableResult
    public func alignment(_ alignment: NSTextAlignment) -> PersonalInfoBuilder {
        label.textAlignment = alignment
        return self
    }
}
