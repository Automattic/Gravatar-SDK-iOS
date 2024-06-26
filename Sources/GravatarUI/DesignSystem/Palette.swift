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

public struct AvatarColors {
    public let border: UIColor
    public let background: UIColor
    public let tint: UIColor?

    public init(border: UIColor, background: UIColor, tint: UIColor? = nil) {
        self.border = border
        self.background = background
        self.tint = tint
    }

    public func with(border: UIColor? = nil, background: UIColor? = nil, tint: UIColor? = nil) -> AvatarColors {
        AvatarColors(
            border: border ?? self.border,
            background: background ?? self.background,
            tint: tint ?? self.tint
        )
    }
}

public struct Palette {
    public let name: String
    public let foreground: ForegroundColors
    public let background: BackgroundColors
    public let avatar: AvatarColors
    public let border: UIColor
    public let placeholder: PlaceholderColors
    public let preferredUserInterfaceStyle: UIUserInterfaceStyle

    /// Creates an instance of `Palette`.
    ///
    /// - Parameters:
    ///   - name: The palete name.
    ///   - foreground: Colors used on foreground elements like text.
    ///   - background: Colors used for the background elements.
    ///   - avatar: Colors used for the profile avatar image.
    ///   - border: Color used for borders.
    ///   - placeholder: Colors to use as placeholders.
    ///   - preferredUserInterfaceStyle: Defines if this palette is a dark or light palette.
    ///   This helps choose the correct images for this palette. Pass `.unspecified` to choose the system's user interface style. Default is `.unspecified`.
    public init(
        name: String,
        foreground: ForegroundColors,
        background: BackgroundColors,
        avatar: AvatarColors,
        border: UIColor,
        placeholder: PlaceholderColors,
        preferredUserInterfaceStyle: UIUserInterfaceStyle = .unspecified
    ) {
        self.name = name
        self.foreground = foreground
        self.background = background
        self.avatar = avatar
        self.border = border
        self.placeholder = placeholder
        self.preferredUserInterfaceStyle = preferredUserInterfaceStyle
    }

    public func with(avatarColors: ((AvatarColors) -> AvatarColors)? = nil) -> Palette {
        Palette(
            name: self.name,
            foreground: self.foreground,
            background: self.background,
            avatar: avatarColors?(self.avatar) ?? self.avatar,
            border: self.border,
            placeholder: self.placeholder,
            preferredUserInterfaceStyle: self.preferredUserInterfaceStyle
        )
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

public typealias PaletteCustomizer = (PaletteType, Palette) -> Palette

private let paletteCustomizerKey: UnsafeMutableRawPointer = .allocate(byteCount: 1, alignment: MemoryLayout<UInt8>.alignment)

public protocol PaletteProvider {
    var palette: Palette { get }
}

public struct PaletteConfig: PaletteProvider {
    public let paletteType: PaletteType
    var paletteCustomizer: PaletteCustomizer? = nil

    public init(paletteType: PaletteType) {
        self.paletteType = paletteType
    }

    public var palette: Palette {
        if let paletteCustomizer {
            return paletteCustomizer(paletteType, paletteType.palette)
        }
        return paletteType.palette
    }

    public mutating func withChanges(_ customizer: PaletteCustomizer?) {
        self.paletteCustomizer = customizer
    }
}

public enum PaletteType: PaletteProvider {
    case light
    case dark
    case system
    case custom(() -> Palette)

    public var palette: Palette {
        var result: Palette
        switch self {
        case .light:
            result = Palette.light
        case .dark:
            result = Palette.dark
        case .system:
            result = Palette.system
        case .custom(let paletteProvider):
            result = paletteProvider()
        }
        return result
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
            avatar: AvatarColors(
                border: .porpoiseGray,
                background: UIColor(
                    light: light.avatar.background,
                    dark: dark.avatar.background
                )
            ),
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
            avatar: AvatarColors(
                border: .porpoiseGray,
                background: .smokeWhite
            ),
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
            avatar: AvatarColors(
                border: .porpoiseGray,
                background: .boatAnchorGray
            ),
            border: .bovineGray,
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
