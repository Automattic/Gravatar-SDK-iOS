import SwiftUI

struct AvatarGrid: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = .DS.Padding.double
        static let maxAvatarWidth: CGFloat = 100
        static let minAvatarWidth: CGFloat = 80
        static let avatarSpacing: CGFloat = 20
        static let selectedBorderWidth: CGFloat = .DS.Padding.half
        static let avatarCornerRadius: CGFloat = .DS.Padding.single
    }

    let gridItems: [GridItem] = [GridItem(
        .adaptive(
            minimum: Constants.minAvatarWidth,
            maximum: Constants.maxAvatarWidth
        ),
        spacing: Constants.avatarSpacing
    )]

    @ObservedObject var grid: AvatarGridModel

    let onAvatarTap: (AvatarImageModel) -> Void
    let onImageSelected: (UIImage) -> Void
    let onRetryUpload: (AvatarImageModel) -> Void

    var body: some View {
        LazyVGrid(columns: gridItems, spacing: Constants.avatarSpacing) {
            SystemImagePickerView {
                PlusButtonView(minSize: Constants.minAvatarWidth, maxSize: Constants.maxAvatarWidth)
            } onImageSelected: { image in
                onImageSelected(image)
            }

            ForEach(grid.avatars) { avatar in
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
                    minWidth: Constants.minAvatarWidth,
                    maxWidth: Constants.maxAvatarWidth,
                    minHeight: Constants.minAvatarWidth,
                    maxHeight: Constants.maxAvatarWidth
                )
                .background(Color(UIColor.secondarySystemBackground))
                .aspectRatio(1, contentMode: .fill)
                .shape(
                    RoundedRectangle(cornerRadius: Constants.avatarCornerRadius),
                    borderColor: .accentColor,
                    borderWidth: grid.selectedAvatar?.id == avatar.id ? Constants.selectedBorderWidth : 0
                )
                .overlay {
                    if avatar.isLoading {
                        OverlayActivityIndicatorView()
                            .cornerRadius(Constants.avatarCornerRadius)
                    } else if avatar.uploadHasFailed {
                        Button(action: {
                            onRetryUpload(avatar)
                        }, label: {
                            ZStack {
                                Rectangle()
                                    .fill(.black.opacity(0.3))
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                            }
                            .cornerRadius(Constants.avatarCornerRadius)
                        })
                        .frame(width: .infinity, height: .infinity)
                        .foregroundColor(Color.white)
                    }
                }.onTapGesture {
                    onAvatarTap(avatar)
                }
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
        } onRetryUpload: { avatar in
            
        }
        .padding()
        Button("Add avatar cell") {
            grid.append(newAvatarModel(nil))
        }
    }
}
