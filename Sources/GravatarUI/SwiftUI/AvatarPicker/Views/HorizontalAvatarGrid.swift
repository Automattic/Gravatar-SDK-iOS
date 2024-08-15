import SwiftUI

struct HorizontalAvatarGrid: View {
    @ObservedObject var grid: AvatarGridModel

    let onAvatarTap: (AvatarImageModel) -> Void
    let onImageSelected: (UIImage) -> Void
    let onRetryUpload: (AvatarImageModel) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: AvatarGridConstants.avatarSpacing) {
                ForEach(grid.avatars, id: \.self) { avatar in
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
            .padding()
        }
    }
}

#Preview {
    let newAvatarModel: @Sendable (UIImage?) -> AvatarImageModel = { image in
        AvatarImageModel(id: UUID().uuidString, source: .local(image: image ?? UIImage()))
    }
    let grid = AvatarGridModel(
        avatars: [
            .init(id: "1", source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256")),
            .init(id: "2", source: .remote(url: "https://gravatar.com/userimage/110207384/db73834576b01b69dd8da1e29877ca07.jpeg?size=256")),
            .init(id: "3", source: .remote(url: "https://gravatar.com/userimage/110207384/3f7095bf2580265d1801d128c6410016.jpeg?size=256")),
            .init(id: "4", source: .remote(url: "https://gravatar.com/userimage/110207384/fbbd335e57862e19267679f19b4f9db8.jpeg?size=256")),
        ]
    )
    grid.selectAvatar(grid.avatars.first)

    return HorizontalAvatarGrid(grid: grid) { avatar in
        grid.selectAvatar(withID: avatar.id)
    } onImageSelected: { _ in
        // No op. Inside the preview.
    } onRetryUpload: { _ in
        // No op. Inside the preview.
    }
}
