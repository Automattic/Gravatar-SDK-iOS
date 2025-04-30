/// Represents a profile editing scope with configuration options for each scope.
public struct QuickEditorScopeOption {
    enum Scope {
        case avatarPicker
        case aboutInfoEditor
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
    @available(iOS 16.0, *)
    public static func avatarPicker(
        _ config: AvatarPickerConfiguration
    ) -> Self {
        .init(
            scope: .avatarPicker,
            avatarPickerConfig: config
        )
    }

    /// Creates a `QuickEditorScopeOption` configured for the avatar picker scope.
    /// - Returns: An instance of `QuickEditorScopeOption` for the avatar picker scope.
    @available(iOS, deprecated: 16.0, renamed: "avatarPicker(_:)", message: "Use `avatarPicker(_:)` with the new configuration instead.")
    public static func avatarPicker() -> Self {
        .init(
            scope: .avatarPicker,
            avatarPickerConfig: .verticalLarge
        )
    }

    /// Creates a `QuickEditorScopeOption` configured for the about info editor scope.
    /// - Parameter config: Configuration to apply to the about editor. Defaults to the standard configuration.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the about info editor scope.
    @available(iOS 16.0, *)
    public static func aboutEditor(
        _ config: AboutEditorConfiguration = .init()
    ) -> Self {
        .init(
            scope: .aboutInfoEditor,
            aboutEditorConfig: config
        )
    }

    /// Creates a `QuickEditorScopeOption` configured for the about info editor scope.
    /// - Parameter config: Configuration to apply to the about editor. Defaults to the standard configuration.
    /// - Returns: A configured instance of `QuickEditorScopeOption` for the about info editor scope.
    @available(iOS, deprecated: 16.0, renamed: "avatarPicker(_:)", message: "Use `aboutEditor(_:)` with the new configuration instead.")
    public static func aboutEditor() -> Self {
        .init(
            scope: .aboutInfoEditor,
            aboutEditorConfig: .init(presentationStyle: .large)
        )
    }
}

/// Represents a profile editing scope with configuration options for each scope.
public struct QuickEditorScopeOptionUIKit {
    private typealias Scope = QuickEditorScopeOption.Scope

    let avatarPickerConfig: AvatarPickerConfiguration
    let aboutEditorConfig: AboutEditorConfiguration
    let scope: QuickEditorScopeOption.Scope

    init(
        scope: QuickEditorScopeOption.Scope,
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
        _ config: AvatarPickerConfiguration
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

    func map() -> QuickEditorScopeOption {
        .init(
            scope: scope,
            avatarPickerConfig: avatarPickerConfig,
            aboutEditorConfig: aboutEditorConfig
        )
    }
}
