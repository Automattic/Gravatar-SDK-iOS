import SwiftUI

struct FailedUploadInfo {
    let avatarLocalID: String
    let supportsRetry: Bool
    let errorMessage: String
}

struct AvatarPickerAvatarView: View {
    let avatar: AvatarImageModel
    let maxLength: CGFloat
    let minLength: CGFloat
    let shouldSelect: () -> Bool
    let onAvatarTap: (AvatarImageModel) -> Void
    let onFailedUploadTapped: (FailedUploadInfo) -> Void
    let onActionTap: (AvatarAction) -> Void

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
            minWidth: minLength,
            maxWidth: maxLength,
            minHeight: minLength,
            maxHeight: maxLength
        )
        .background(Color(UIColor.secondarySystemBackground))
        .aspectRatio(1, contentMode: .fill)
        .shape(
            RoundedRectangle(cornerRadius: AvatarGridConstants.avatarCornerRadius),
            borderColor: Color(uiColor: .gravatarBlue),
            borderWidth: shouldSelect() ? AvatarGridConstants.selectedBorderWidth : 0
        )
        .overlay {
            switch avatar.state {
            case .loading:
                DimmingActivityIndicator()
                    .cornerRadius(AvatarGridConstants.avatarCornerRadius)
            case .error(let supportsRetry, let errorMessage):
                DimmingErrorButton {
                    onFailedUploadTapped(
                        .init(
                            avatarLocalID: avatar.id,
                            supportsRetry: supportsRetry,
                            errorMessage: errorMessage
                        )
                    )
                }
                .cornerRadius(AvatarGridConstants.avatarCornerRadius)
            case .loaded:
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        actionsMenu()
                    }
                }
            }
        }.onTapGesture {
            onAvatarTap(avatar)
        }
    }

    func ellipsisView() -> some View {
        Image("more-horizontal", bundle: Bundle.module).renderingMode(.template)
            .tint(.white)
            .background(Color(uiColor: UIColor.gravatarBlack.withAlphaComponent(0.4)))
            .cornerRadius(2)
            .padding(CGFloat.DS.Padding.half)
    }

    func actionsMenu() -> some View {
        Menu {
            ForEach(AvatarAction.allCases) { action in
                Button(role: action.role) {
                    onActionTap(action)
                } label: {
                    Label {
                        Text(action.localizedTitle)
                    } icon: {
                        action.icon
                    }
                }
            }
        } label: {
            ellipsisView()
        }
    }
}

#Preview {
    let avatar = AvatarImageModel(id: "1", source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256"))
    return AvatarPickerAvatarView(avatar: avatar, maxLength: AvatarGridConstants.maxAvatarWidth, minLength: AvatarGridConstants.minAvatarWidth) {
        false
    } onAvatarTap: { _ in
    } onFailedUploadTapped: { _ in
    } onActionTap: { _ in
    }
}
