import SwiftUI

enum AvatarGridConstants {
    static let horizontalPadding: CGFloat = .DS.Padding.double
    static let maxAvatarWidth: CGFloat = 100
    static let minAvatarWidth: CGFloat = 80
    static let avatarSpacing: CGFloat = 20
    static let selectedBorderWidth: CGFloat = .DS.Padding.half
    static let avatarCornerRadius: CGFloat = .DS.Padding.single
}

struct AvatarGrid: View {
    let gridItems: [GridItem] = [GridItem(
        .adaptive(
            minimum: AvatarGridConstants.minAvatarWidth,
            maximum: AvatarGridConstants.maxAvatarWidth
        ),
        spacing: AvatarGridConstants.avatarSpacing
    )]

    @ObservedObject var grid: AvatarGridModel

    let onAvatarTap: (AvatarImageModel) -> Void
    let onImageSelected: (UIImage) -> Void
    let onRetryUpload: (AvatarImageModel) -> Void

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: AvatarGridConstants.avatarSpacing) {
            SystemImagePickerView {
                PlusButtonView(minSize: AvatarGridConstants.minAvatarWidth, maxSize: AvatarGridConstants.maxAvatarWidth)
            } onImageSelected: { image in
                onImageSelected(image)
            }

            ForEach(grid.avatars) { avatar in
                AvatarPickerAvatarView(
                    avatar: avatar,
                    shouldSelect: {
                        grid.selectedAvatar?.id == avatar.id
                    },
                    onAvatarTap: onAvatarTap,
                    onImageSelected: onImageSelected,
                    onRetryUpload: onRetryUpload
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
        AvatarGrid(grid: grid) { avatar in
            grid.selectAvatar(withID: avatar.id)
        } onImageSelected: { image in
            grid.append(newAvatarModel(image))
        } onRetryUpload: { _ in
            // No op. inside the preview.
        }
        .padding()
        Button("Add avatar cell") {
            grid.append(newAvatarModel(nil))
        }
    }
}
