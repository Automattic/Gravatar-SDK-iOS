
/// Defines a type that can adapt to ``PaletteType`` changes.
public protocol PaletteRefreshable {
    func refresh(with paletteType: PaletteType)
}
