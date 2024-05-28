import UIKit

@MainActor
public struct DisplayNameBuilder {
    let label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    @discardableResult
    public func content(_ model: DisplayNameModel) -> DisplayNameBuilder {
        label.text = model.displayName
        label.font = .DS.title2
        label.numberOfLines = 0
        return self
    }

    @discardableResult
    public func palette(_ paletteType: PaletteType) -> DisplayNameBuilder {
        label.textColor = paletteType.palette.foreground.primary
        return self
    }

    @discardableResult
    func font(_ font: UIFont) -> DisplayNameBuilder {
        label.font = font
        return self
    }
}
