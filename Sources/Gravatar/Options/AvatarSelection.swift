/// Defines how to handle avatar selection after uploading a new avatar
@available(*, deprecated, renamed: "AvatarUploadSelectionPolicy")
public enum AvatarSelection: Equatable, Sendable {
    case preserveSelection
    case selectUploadedImage(for: Email)
    case selectUploadedImageIfNoneSelected(for: Email)

    public static func allCases(for email: Email) -> [AvatarSelection] {
        [
            .preserveSelection,
            .selectUploadedImage(for: email),
            .selectUploadedImageIfNoneSelected(for: email),
        ]
    }

    func map() -> AvatarUploadSelectionPolicy {
        switch self {
        case .preserveSelection:
            .preserveSelection
        case .selectUploadedImage(let email):
            .selectUploadedImage(for: .email(email))
        case .selectUploadedImageIfNoneSelected(let email):
            .selectUploadedImageIfNoneSelected(for: .email(email))
        }
    }
}

/// Determines if the uploaded image should be set as the avatar for the profile.
public struct AvatarUploadSelectionPolicy: Equatable, Sendable {
    enum SelectionPolicy: Equatable, Sendable {
        case preserveSelection
        case selectUploadedImage(for: ProfileIdentifier)
        case selectUploadedImageIfNoneSelected(for: ProfileIdentifier)
    }

    let policy: SelectionPolicy

    // Do not set the uploaded image as the avatar for the profile.
    public static let preserveSelection: AvatarUploadSelectionPolicy = .init(policy: .preserveSelection)
    // Set the uploaded image as the avatar for the profile.
    public static func selectUploadedImage(for profileID: ProfileIdentifier) -> AvatarUploadSelectionPolicy {
        .init(policy: .selectUploadedImage(for: profileID))
    }

    // Set the uploaded image as the avatar for the profile only if there was no other avatar previously selected.
    public static func selectUploadedImageIfNoneSelected(for profileID: ProfileIdentifier) -> AvatarUploadSelectionPolicy {
        .init(policy: .selectUploadedImageIfNoneSelected(for: profileID))
    }

    /// A list of all policies available, set up with the given profile ID.
    /// - Parameter profileID: The user's profile ID
    /// - Returns: A list of all policies available
    public static func allCases(for profileID: ProfileIdentifier) -> [AvatarUploadSelectionPolicy] {
        [
            .preserveSelection,
            .selectUploadedImage(for: profileID),
            .selectUploadedImageIfNoneSelected(for: profileID),
        ]
    }

    public var isPreserveSelectionPolicy: Bool {
        policy == .preserveSelection
    }

    public var isSelectUploadedImagePolicy: Bool {
        switch policy {
        case .selectUploadedImage:
            true
        default: false
        }
    }

    public var isSelectUploadedImageIfNoneSelectedPolicy: Bool {
        switch policy {
        case .selectUploadedImageIfNoneSelected:
            true
        default: false
        }
    }
}
