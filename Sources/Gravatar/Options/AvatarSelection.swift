/// Defines how to handle avatar selection after uploading a new avatar
public enum AvatarSelection: Equatable, Sendable {
    case preserveSelection
    case selectUploadedImage(for: ProfileIdentifier)
    case selectUploadedImageIfNoneSelected(for: ProfileIdentifier)

    public static func allCases(for profileID: ProfileIdentifier) -> [AvatarSelection] {
        [
            .preserveSelection,
            .selectUploadedImage(for: profileID),
            .selectUploadedImageIfNoneSelected(for: profileID),
        ]
    }
}
