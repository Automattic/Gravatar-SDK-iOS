import UIKit

public class QuickEditorConfiguration {
    let interfaceStyle: UIUserInterfaceStyle
    let avatarPickerConfiguration: AvatarPickerConfiguration

    static var `default`: QuickEditorConfiguration { .init() }

    public init(
        interfaceStyle: UIUserInterfaceStyle? = nil,
        avatarPickerConfiguration: AvatarPickerConfiguration? = nil
    ) {
        self.interfaceStyle = interfaceStyle ?? .unspecified
        self.avatarPickerConfiguration = avatarPickerConfiguration ?? .default
    }
}

/// Configuration which will be applied to the avatar picker screen.
public struct AvatarPickerConfiguration: Sendable {
    let contentLayout: AvatarPickerContentLayoutWithPresentation

    public init(contentLayout: AvatarPickerContentLayoutWithPresentation) {
        self.contentLayout = contentLayout
    }

    static let `default` = AvatarPickerConfiguration(
        contentLayout: .horizontal(presentationStyle: .intrinsicHeight)
    )
}
