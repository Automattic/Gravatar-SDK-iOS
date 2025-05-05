/// Represents a profile editing scope with configuration options for each scope.
public struct QuickEditorScopeOption {
    enum Scope {
        case avatarPicker
        case aboutInfoEditor
        case avatarPickerAndAboutInfoEditor
    }

    let avatarPickerConfig: AvatarPickerConfiguration
    let aboutEditorConfig: AboutEditorConfiguration
    let scope: Scope

    init(
        scope: Scope,
        avatarPickerConfig: AvatarPickerConfiguration = .horizontalInstrinsicHeight,
        aboutEditorConfig: AboutEditorConfiguration = .init(presentationStyle: .expandableMedium())
    ) {
        self.avatarPickerConfig = avatarPickerConfig
        self.aboutEditorConfig = aboutEditorConfig
        self.scope = scope
    }

    /// Creates a `QuickEditorScopeOption` configured for the avatar picker scope.
    /// - Parameter config: Configuration to apply to the avatar picker.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the avatar picker scope.
    public static func avatarPicker(
        _ config: AvatarPickerConfiguration = .horizontalInstrinsicHeight
    ) -> Self {
        .init(
            scope: .avatarPicker,
            avatarPickerConfig: config
        )
    }

    /// Creates a `QuickEditorScopeOption` configured for the about info editor scope.
    /// - Parameter config: Configuration to apply to the about editor. Defaults to the standard configuration.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the about info editor scope.
    public static func aboutEditor(
        _ config: AboutEditorConfiguration = .init()
    ) -> Self {
        .init(
            scope: .aboutInfoEditor,
            aboutEditorConfig: config
        )
    }

    public static func avatarPickerAndAboutInfoEditor(
        avatarPickerConfig: AvatarPickerConfiguration = .horizontalInstrinsicHeight,
        aboutEditorFields fields: AboutInfoField = .all
    ) -> Self {
        .init(
            scope: .avatarPickerAndAboutInfoEditor,
            avatarPickerConfig: avatarPickerConfig,
            aboutEditorConfig: .init(presentationStyle: .expandableMedium(), fields: fields)
        )
    }
}

/// Represents a profile editing scope with configuration options for each scope.
@available(iOS, deprecated: 16.0, renamed: "QuickEditorScopeOption")
public struct QuickEditorScopeOptionOld {
    typealias Scope = QuickEditorScopeOption.Scope

    let avatarPickerConfig: AvatarPickerConfiguration
    let aboutEditorConfig: AboutEditorConfiguration
    let scope: Scope

    init(
        scope: Scope
    ) {
        self.avatarPickerConfig = .verticalLarge
        self.aboutEditorConfig = .init(presentationStyle: .large)
        self.scope = scope
    }

    /// Creates a `QuickEditorScopeOption` configured for the avatar picker scope.
    /// - Returns: An instance of `QuickEditorScopeOption` for the avatar picker scope.
    public static func avatarPicker() -> Self {
        .init(
            scope: .avatarPicker
        )
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
        .init(scope: scope, avatarPickerConfig: avatarPickerConfig, aboutEditorConfig: aboutEditorConfig)
    }
}
