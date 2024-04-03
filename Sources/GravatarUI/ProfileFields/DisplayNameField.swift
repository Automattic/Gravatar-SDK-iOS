import UIKit

public struct DisplayNameField: PaletteRefreshable {
    var label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    public func update(with model: DisplayNameModel, paletteType: PaletteType) {
        label.text = model.displayName ?? model.fullName ?? model.userName
        label.font = .DS.title1
        label.numberOfLines = 0
        refresh(with: paletteType)
    }

    public func refresh(with paletteType: PaletteType) {
        label.textColor = paletteType.palette.foreground.primary
    }
}
