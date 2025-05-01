import UIKit

public class QuickEditorConfiguration {
    let interfaceStyle: UIUserInterfaceStyle
    let customImageEditorProvider: CustomImageEditorControllerProvider?

    static var `default`: QuickEditorConfiguration { .init() }

    public init(
        interfaceStyle: UIUserInterfaceStyle? = nil,
        customImageEditorProvider: CustomImageEditorControllerProvider? = nil
    ) {
        self.interfaceStyle = interfaceStyle ?? .unspecified
        self.customImageEditorProvider = customImageEditorProvider
    }
}

/// Configuration which will be applied to the avatar picker.
public struct AvatarPickerConfiguration: Sendable {
    let contentLayout: AvatarPickerContentLayout

    public init(
        contentLayout: AvatarPickerContentLayout
    ) {
        self.contentLayout = contentLayout
    }
}

/// Configuration which will be applied to the About info editor.
public struct AboutEditorConfiguration: Sendable {
    let presentationStyle: VerticalContentPresentationStyle
    let fields: AboutInfoField

    public init(
        presentationStyle: VerticalContentPresentationStyle = .expandableMedium(),
        fields: AboutInfoField = AboutInfoField.all
    ) {
        self.presentationStyle = presentationStyle
        self.fields = fields
    }
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
