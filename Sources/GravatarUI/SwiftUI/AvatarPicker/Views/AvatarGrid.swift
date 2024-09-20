import SwiftUI

enum AvatarGridConstants {
    static let horizontalPadding: CGFloat = .DS.Padding.double
    static let maxAvatarWidth: CGFloat = 100
    static let minAvatarWidth: CGFloat = 80
    static let avatarSpacing: CGFloat = 20
    static let selectedBorderWidth: CGFloat = .DS.Padding.half
    static let avatarCornerRadius: CGFloat = .DS.Padding.single
}

struct AvatarGrid<ImageEditor: ImageEditorView>: View {
    let gridItems: [GridItem] = [GridItem(
        .adaptive(
            minimum: AvatarGridConstants.minAvatarWidth,
            maximum: AvatarGridConstants.maxAvatarWidth
        ),
        spacing: AvatarGridConstants.avatarSpacing
    )]

    @ObservedObject var grid: AvatarGridModel
    var customImageEditor: ImageEditorBlock<ImageEditor>?
    let onAvatarTap: (AvatarImageModel) -> Void
    let onImagePickerDidPickImage: (UIImage) -> Void
    let onRetryUpload: (AvatarImageModel) -> Void
    let onDeleteFailed: (AvatarImageModel) -> Void

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: AvatarGridConstants.avatarSpacing) {
            SystemImagePickerView(
                label: {
                    PlusButtonView(minSize: AvatarGridConstants.minAvatarWidth, maxSize: AvatarGridConstants.maxAvatarWidth)
                },
                customEditor: customImageEditor,
                onImageSelected: { image in
                    onImagePickerDidPickImage(image)
                }
            )

            ForEach(grid.avatars) { avatar in
                AvatarPickerAvatarView(
                    avatar: avatar,
                    maxLength: AvatarGridConstants.maxAvatarWidth,
                    minLength: AvatarGridConstants.minAvatarWidth,
                    shouldSelect: {
                        grid.selectedAvatar?.id == avatar.id
                    },
                    onAvatarTap: onAvatarTap,
                    onRetryUpload: onRetryUpload,
                    onDeleteFailed: onDeleteFailed
                )
            }
        }
    }
}

#Preview {
    let newAvatarModel: @Sendable (UIImage?) -> AvatarImageModel = { image in
        AvatarImageModel(id: UUID().uuidString, source: .local(image: image ?? UIImage()))
    }
    let initialAvatarCell = newAvatarModel(nil)
    let grid = AvatarGridModel(
        avatars: [initialAvatarCell]
    )
    grid.selectAvatar(initialAvatarCell)
    return VStack {
        AvatarGrid<NoCustomEditor>(grid: grid) { avatar in
            grid.selectAvatar(withID: avatar.id)
        } onImagePickerDidPickImage: { image in
            grid.append(newAvatarModel(image))
        } onRetryUpload: { _ in
            // No op. inside the preview.
        } onDeleteFailed: { _ in
            // No op. inside the preview.
        }
        .padding()
        Button("Add avatar cell") {
            grid.append(newAvatarModel(nil))
        }
    }
}
