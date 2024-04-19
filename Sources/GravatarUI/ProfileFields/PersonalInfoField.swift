import UIKit

public struct PersonalInfoBuilder {
    public static var defaultPersonalInfo: [PersonalInfoLine] {
        [
            .init([.jobTitle]),
            .init([.namePronunciation, .pronouns, .location]),
        ]
    }

    static let defaultSeparator: String = "・"

    let label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    @discardableResult
    public func content(
        _ model: PersonalInfoModel,
        lines: [PersonalInfoLine] = Self.defaultPersonalInfo,
        separator: String? = nil
    ) -> PersonalInfoBuilder {
        let separator = separator ?? Self.defaultSeparator
        let text = lines.map { line in
            line.buildingBlocks
                .compactMap { $0.text(from: model) }
                .joined(separator: "\(separator)")
        }.filter { !$0.isEmpty }.joined(separator: "\n")

        label.text = text
        label.font = .DS.Body.xSmall
        label.numberOfLines = 0
        return self
    }

    @discardableResult
    public func palette(_ paletteType: PaletteType) -> PersonalInfoBuilder {
        label.textColor = paletteType.palette.foreground.secondary
        return self
    }

    @discardableResult
    func alignment(_ alignment: NSTextAlignment) -> PersonalInfoBuilder {
        label.textAlignment = alignment
        return self
    }
}
