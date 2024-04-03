import UIKit

public struct AboutMeField: PaletteRefreshable {
    var label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    public func update(with model: AboutMeModel, paletteType: PaletteType) {
        label.text = model.aboutMe
        label.font = .DS.Body.small
        label.numberOfLines = 2
        refresh(with: paletteType)
    }

    public func refresh(with paletteType: PaletteType) {
        label.textColor = paletteType.palette.foreground.primarySlightlyDimmed
    }
}
