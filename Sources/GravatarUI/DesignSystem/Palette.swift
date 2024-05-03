import Foundation
import UIKit

public struct ForegroundColors {
    public let primary: UIColor
    public let primarySlightlyDimmed: UIColor
    public let secondary: UIColor
    public init(primary: UIColor, primarySlightlyDimmed: UIColor, secondary: UIColor) {
        self.primary = primary
        self.primarySlightlyDimmed = primarySlightlyDimmed
        self.secondary = secondary
    }
}

public struct BackgroundColors {
    public let primary: UIColor
    public init(primary: UIColor) {
        self.primary = primary
    }
}

public struct Palette {
    public let name: String
    public let foreground: ForegroundColors
    public let background: BackgroundColors
    public let avatarBorder: UIColor
    public let border: UIColor
    public let placeholder: PlaceholderColors
    public let preferredUserInterfaceStyle: UIUserInterfaceStyle
    /// Creates an instance of `Palette`.
    ///
    /// - Parameters:
    ///   - name: The palete name.
    ///   - foreground: Colors used on foreground elements like text.
    ///   - background: Colors used for the background elements.
    ///   - avatarBorder: Color used around the profile avatar image.
    ///   - placeholder: Colors to use as placeholders.
    ///   - preferredUserInterfaceStyle: Defines if this palette is a dark or light palette.
    ///   This helps choose the correct images for this palette. Pass `.unspecified` to choose the system's user interface style. Default is `.unspecified`.
    init(
        name: String,
        foreground: ForegroundColors,
        background: BackgroundColors,
        avatarBorder: UIColor,
        border: UIColor,
        placeholder: PlaceholderColors,
        preferredUserInterfaceStyle: UIUserInterfaceStyle = .unspecified
    ) {
        self.name = name
        self.foreground = foreground
        self.background = background
        self.avatarBorder = avatarBorder
        self.border = border
        self.placeholder = placeholder
        self.preferredUserInterfaceStyle = preferredUserInterfaceStyle
    }
}

public struct PlaceholderColors {
    var backgroundColor: UIColor
    var loadingAnimationColors: [UIColor]
    public init(backgroundColor: UIColor, loadingAnimationColors: [UIColor]) {
        self.backgroundColor = backgroundColor
        self.loadingAnimationColors = loadingAnimationColors
    }
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
            border: .init(
                light: light.border,
                dark: dark.border
            ),
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
            border: .porpoiseGray,
            placeholder: PlaceholderColors(
                backgroundColor: .smokeWhite,
                loadingAnimationColors: [.smokeWhite, .bleachedSilkWhite]
            ),
            preferredUserInterfaceStyle: .light
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
            border: .orchidBlack,
            placeholder: PlaceholderColors(
                backgroundColor: .boatAnchorGray,
                loadingAnimationColors: [.boatAnchorGray, .spanishGray]
            ),
            preferredUserInterfaceStyle: .dark
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
