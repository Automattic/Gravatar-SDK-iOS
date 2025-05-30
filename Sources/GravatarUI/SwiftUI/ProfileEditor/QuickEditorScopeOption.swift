import SwiftUI

/// Represents a profile editing scope with configuration options for each scope.
public struct QuickEditorScopeOption {
    enum Scope {
        case avatarPicker(AvatarPickerConfiguration)
        case aboutInfoEditor(AboutEditorConfiguration)
        case avatarPickerAndAboutInfoEditor(AvatarPickerAndAboutEditorConfiguration)
    }

    let scope: Scope

    init(scope: Scope) {
        self.scope = scope
    }

    /// Creates a `QuickEditorScopeOption` configured for the avatar picker scope.
    ///
    /// Displays the UI for managing user avatars.
    ///
    /// ![](vertical-large)
    ///
    /// - Parameter config: Configuration to apply to the avatar picker.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the avatar picker scope.
    public static func avatarPicker(
        _ config: AvatarPickerConfiguration = .horizontalInstrinsicHeight
    ) -> Self {
        .init(
            scope: .avatarPicker(config)
        )
    }

    /// Creates a `QuickEditorScopeOption` configured for the about info editor scope.
    ///
    /// Displays the UI for editing the "About" section of the Gravatar profile.
    /// ![](about-editor)
    /// - Parameter config: Configuration to apply to the about editor. Defaults to the standard configuration.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the about info editor scope.
    public static func aboutEditor(
        _ config: AboutEditorConfiguration = .init()
    ) -> Self {
        .init(
            scope: .aboutInfoEditor(config)
        )
    }

    /// Creates a `QuickEditorScopeOption` configured for the avatar picker & about info editor scope.
    ///
    /// This scope  allows switching between Avatar Picker and About editor from within the Quick Editor.
    /// - Parameter avatarPickerAndAboutEditorConfig: Configuration to apply to the avatar picker and about editor. Defaults to the standard configuration.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the avatar picker & about info editor scope.
    public static func avatarPickerAndAboutInfoEditor(
        _ avatarPickerAndAboutEditorConfig: AvatarPickerAndAboutEditorConfiguration = .init()
    ) -> Self {
        .init(
            scope: .avatarPickerAndAboutInfoEditor(avatarPickerAndAboutEditorConfig)
        )
    }
}

extension QuickEditorScopeOption {
    var initialPage: QuickEditorPage {
        switch scope {
        case .avatarPicker:
            .avatarPicker
        case .aboutInfoEditor:
            .aboutEditor
        case .avatarPickerAndAboutInfoEditor(let config):
            switch config.initialPage {
            case .avatarPicker:
                .avatarPicker
            case .aboutEditor:
                .aboutEditor
            }
        }
    }
}

/// Represents a profile editing scope with configuration options for each scope.
@available(iOS, deprecated: 16.0, renamed: "QuickEditorScopeOption")
public struct QuickEditorScopeOptionOld {
    enum ScopeOld {
        case avatarPicker
        case aboutInfoEditor
        case avatarPickerAndAboutInfoEditor
    }

    typealias Scope = QuickEditorScopeOption.Scope

    let scope: Scope

    init(scope: ScopeOld) {
        self.scope = switch scope {
        case .avatarPicker:
            .avatarPicker(.verticalLarge)
        case .aboutInfoEditor:
            .aboutInfoEditor(.init(presentationStyle: .large()))
        case .avatarPickerAndAboutInfoEditor:
            .avatarPickerAndAboutInfoEditor(.init(contentLayout: .vertical(presentationStyle: .large)))
        }
    }

    /// Creates a `QuickEditorScopeOption` configured for the avatar picker scope.
    /// - Returns: An instance of `QuickEditorScopeOption` for the avatar picker scope.
    public static func avatarPicker() -> Self {
        .init(scope: .avatarPicker)
    }

    /// Creates a `QuickEditorScopeOption` configured for the about info editor scope.
    /// - Parameter config: Configuration to apply to the about editor. Defaults to the standard configuration.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the about info editor scope.
    public static func aboutEditor() -> Self {
        .init(scope: .aboutInfoEditor)
    }

    public static func avatarPickerAndAboutInfoEditor(
    ) -> Self {
        .init(scope: .avatarPickerAndAboutInfoEditor)
    }

    func map() -> QuickEditorScopeOption {
        .init(scope: scope)
    }
}
