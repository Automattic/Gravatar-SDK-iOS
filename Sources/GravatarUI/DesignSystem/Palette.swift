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
    public let avatarBorder: UIColor
    public let placeholder: PlaceholderColors
}

public struct PlaceholderColors {
    var backgroundColor: UIColor
    var loadingAnimationColors: [UIColor]
}

public enum PaletteType {
    case light
    case dark
    case system
    case custom(() -> Palette)

    public var palette: Palette {
        switch self {
        case .light:
            Palette.light
        case .dark:
            Palette.dark
        case .system:
            Palette.system
        case .custom(let paletteProvider):
            paletteProvider()
        }
    }

    public var name: String {
        palette.name
    }
}

extension Palette {
    static var system: Palette {
        .init(
            name: "System Default",
            foreground: .init(
                primary: UIColor(
                    light: light.foreground.primary,
                    dark: dark.foreground.primary
                ),
                primarySlightlyDimmed: UIColor(
                    light: light.foreground.primarySlightlyDimmed,
                    dark: dark.foreground.primarySlightlyDimmed
                ),
                secondary: UIColor(
                    light: light.foreground.secondary,
                    dark: dark.foreground.secondary
                )
            ),
            background: .init(primary: UIColor(
                light: light.background.primary,
                dark: dark.background.primary
            )),
            avatarBorder: .porpoiseGray,
            placeholder: PlaceholderColors(
                backgroundColor: UIColor(
                    light: light.placeholder.backgroundColor,
                    dark: dark.placeholder.backgroundColor
                ),
                loadingAnimationColors: systemPlaceholderAnimationColors()
            )
        )
    }

    public static var light: Palette {
        .init(
            name: "Light",
            foreground: .init(
                primary: .black,
                primarySlightlyDimmed: .gravatarBlack,
                secondary: .dugongGray
            ),
            background: .init(primary: .white),
            avatarBorder: .porpoiseGray,
            placeholder: PlaceholderColors(
                backgroundColor: .smokeWhite,
                loadingAnimationColors: [.smokeWhite, .bleachedSilkWhite]
            )
        )
    }

    static var dark: Palette {
        .init(
            name: "Dark",
            foreground: .init(
                primary: .white,
                primarySlightlyDimmed: .white,
                secondary: .snowflakeWhite60
            ),
            background: .init(primary: .gravatarBlack),
            avatarBorder: .porpoiseGray,
            placeholder: PlaceholderColors(
                backgroundColor: .boatAnchorGray,
                loadingAnimationColors: [.boatAnchorGray, .spanishGray]
            )
        )
    }

    private static func systemPlaceholderAnimationColors() -> [UIColor] {
        var colors: [UIColor] = []
        let count = min(light.placeholder.loadingAnimationColors.count, dark.placeholder.loadingAnimationColors.count)
        for i in 0 ..< count {
            colors.append(UIColor(
                light: light.placeholder.loadingAnimationColors[i],
                dark: dark.placeholder.loadingAnimationColors[i]
            ))
        }
        return colors
    }
}
