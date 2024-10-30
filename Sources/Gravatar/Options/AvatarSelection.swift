/// Defines how to handle avatar selection after uploading a new avatar
public enum AvatarSelection: Equatable {
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
}
