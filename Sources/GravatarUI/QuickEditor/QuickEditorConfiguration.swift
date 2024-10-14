import UIKit

public class QuickEditorConfiguration {
    let interfaceStyle: UIUserInterfaceStyle

    static var `default`: QuickEditorConfiguration { .init() }

    public init(
        interfaceStyle: UIUserInterfaceStyle? = nil
    ) {
        self.interfaceStyle = interfaceStyle ?? .unspecified
    }
}

/// Configuration which will be applied to the avatar picker screen.
public struct AvatarPickerConfiguration: Sendable {
    let contentLayout: AvatarPickerContentLayout

    public init(contentLayout: AvatarPickerContentLayout) {
        self.contentLayout = contentLayout
    }

    static let `default` = AvatarPickerConfiguration(
        contentLayout: .horizontal(presentationStyle: .intrinsicHeight)
    )
}

extension AvatarPickerConfiguration {
    /// Configuration where the avatars collection scrolls horizontally, and the modal sheet height is equal to the content height.
    public static var horizontalInstrinsicHeight: AvatarPickerConfiguration { .init(contentLayout: .horizontal(presentationStyle: .intrinsicHeight)) }
    /// Configuration where the avatars collection scrolls vertically, and the modal sheet height covers the screen.
    /// This is equal to a `large` sheet detent.
    public static var verticalLarge: AvatarPickerConfiguration { .init(contentLayout: .vertical(presentationStyle: .large)) }
    /// Configuration where the avatars collection scrolls vertically, with a medium detent height.
    /// By default, scrolling the sheet upwards will transition the sheet presentation to a large detent.
    /// - Parameters:
    ///   - initialFraction: The initial detent height, as a fraction of the maximum height.
    ///   - prioritizeScrollOverResize: When set to `true` scrolling the avatar collection vertically will take presedent.
    ///   Otherwise, the modal sheet resize will take presedence.
    /// - Returns: A configured ``AvatarPickerConfiguration`` instance.
    public static func verticalMediumExpandable(initialFraction: CGFloat = 0.7, prioritizeScrollOverResize: Bool = false) -> AvatarPickerConfiguration {
        .init(contentLayout: .vertical(presentationStyle: .expandableMedium(
            initialFraction: initialFraction,
            prioritizeScrollOverResize: prioritizeScrollOverResize
        )))
    }
}
