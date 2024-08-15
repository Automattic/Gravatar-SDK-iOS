import SwiftUI

struct AvatarPickerAvatarView: View {
    let avatar: AvatarImageModel
    let shouldSelect: () -> Bool
    let onAvatarTap: (AvatarImageModel) -> Void
    let onImageSelected: (UIImage) -> Void
    let onRetryUpload: (AvatarImageModel) -> Void

    var body: some View {
        AvatarView(
            url: avatar.url,
            placeholder: avatar.localImage,
            loadingView: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        )
        .scaledToFill()
        .frame(
            minWidth: AvatarGridConstants.minAvatarWidth,
            maxWidth: AvatarGridConstants.maxAvatarWidth,
            minHeight: AvatarGridConstants.minAvatarWidth,
            maxHeight: AvatarGridConstants.maxAvatarWidth
        )
        .background(Color(UIColor.secondarySystemBackground))
        .aspectRatio(1, contentMode: .fill)
        .shape(
            RoundedRectangle(cornerRadius: AvatarGridConstants.avatarCornerRadius),
            borderColor: .accentColor,
            borderWidth: shouldSelect() ? AvatarGridConstants.selectedBorderWidth : 0
        )
        .overlay {
            if avatar.isLoading {
                OverlayActivityIndicatorView()
                    .cornerRadius(AvatarGridConstants.avatarCornerRadius)
            } else if avatar.uploadHasFailed {
                DimmingRetryButton {
                    onRetryUpload(avatar)
                }
                .cornerRadius(AvatarGridConstants.avatarCornerRadius)
            }
        }.onTapGesture {
            onAvatarTap(avatar)
        }
    }
}

#Preview {
    let avatar = AvatarImageModel(id: "1", source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256"))
    return AvatarPickerAvatarView(avatar: avatar) {
        false
    } onAvatarTap: { _ in

    } onImageSelected: { _ in

    } onRetryUpload: { _ in
    }
}
