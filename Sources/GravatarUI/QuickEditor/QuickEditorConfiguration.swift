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
    public static var horizontalInstrinsicHeight: AvatarPickerConfiguration { .init(contentLayout: .horizontal(presentationStyle: .intrinsicHeight)) }
    public static var verticalLarge: AvatarPickerConfiguration { .init(contentLayout: .vertical(presentationStyle: .large)) }
    public static var verticalScrollable: AvatarPickerConfiguration { .init(contentLayout: .vertical(presentationStyle: .expandableMedium())) }
}
