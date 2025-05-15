/// A marker protocol representing a type of update that has occurred.
///
/// Concrete implementations are defined under the `QuickEditorUpdate` namespace.
///
/// Example usage:
///
/// As an example:
/// ```swift
/// updateHandler: { updateType in
///     switch updateType {
///     case is QuickEditorUpdate.Avatar:
///         // Handle avatar update
///     case let update as QuickEditorUpdate.AboutInfo:
///         // Handle profile update using `update.profile`
///     default:
///         break
///     }
/// }
/// ```
public protocol QuickEditorUpdateType {}

/// A namespace for concrete update types conforming to `QuickEditorUpdateType`.
public enum QuickEditorUpdate {
    /// Represents an update to the user's avatar.
    public struct Avatar: QuickEditorUpdateType {}

    /// Represents an update to the user's profile information.
    public struct AboutInfo: QuickEditorUpdateType {
        /// The updated Profile model.
        public let profile: Profile
    }
}
