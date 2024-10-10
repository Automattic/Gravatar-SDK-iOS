/// Defines how to handle avatar selection after uploading a new avatar
public enum AvatarSelection {
    case preserveSelection
    case selectUploadedImage(for: Email)
    case selectUploadedImageIfNoneSelected(for: Email)
}
