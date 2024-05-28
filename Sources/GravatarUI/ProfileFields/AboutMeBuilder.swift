import UIKit

@MainActor
public struct AboutMeBuilder {
    let label: UILabel
    init(label: UILabel) {
        self.label = label
    }

    @discardableResult
    public func content(_ model: AboutMeModel) -> AboutMeBuilder {
        label.text = model.description
        label.font = .DS.Body.xSmall
        label.numberOfLines = 2
        return self
    }

    @discardableResult
    public func palette(_ paletteType: PaletteType) -> AboutMeBuilder {
        label.textColor = paletteType.palette.foreground.primarySlightlyDimmed
        return self
    }
}
