import Foundation
import UIKit

public struct ForegroundColors {
    public let primary: UIColor
    public let primarySlightlyDimmed: UIColor
    public let secondary: UIColor
}

public struct BackgroundColors {
    public let primary: UIColor
}

public struct Palette {
    public let name: String
    public let foreground: ForegroundColors
    public let background: BackgroundColors
}

public enum PaletteType {
    case light
    case dark
    case system
    case custom(() -> Palette)

    public var palette: Palette {
        switch self {
        case .light:
            Self.lightPalette
        case .dark:
            Self.darkPalette
        case .system:
            Self.systemPalette
        case .custom(let paletteProvider):
            paletteProvider()
        }
    }

    public var name: String {
        palette.name
    }

    static var systemPalette: Palette {
        .init(
            name: "System Default",
            foreground: .init(
                primary: UIColor(
                    light: lightPalette.foreground.primary,
                    dark: darkPalette.foreground.primary
                ),
                primarySlightlyDimmed: UIColor(
                    light: lightPalette.foreground.primarySlightlyDimmed,
                    dark: darkPalette.foreground.primarySlightlyDimmed
                ),
                secondary: UIColor(
                    light: lightPalette.foreground.secondary,
                    dark: darkPalette.foreground.secondary
                )
            ),
            background: .init(primary: UIColor(
                light: lightPalette.background.primary,
                dark: darkPalette.background.primary
            ))
        )
    }

    public static var lightPalette: Palette {
        .init(
            name: "Light",
            foreground: .init(
                primary: .black,
                primarySlightlyDimmed: .gravatarBlack,
                secondary: .dugong
            ),
            background: .init(primary: .white)
        )
    }

    static var darkPalette: Palette {
        .init(
            name: "Dark",
            foreground: .init(
                primary: .white,
                primarySlightlyDimmed: .white,
                secondary: .snowflake60
            ),
            background: .init(primary: .gravatarBlack)
        )
    }
}
