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
        ZStack(alignment: .bottomTrailing) {
            AvatarView(
                url: avatar.url,
                placeholderView: {
                    avatar.localImage?.resizable()
                },
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
                    EmptyView()
                }
            }.onTapGesture {
                onAvatarTap(avatar)
            }
            switch avatar.state {
            case .loaded:
                actionsMenu()
            default:
                EmptyView()
            }
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
            Section {
                button(for: .share)
                if #available(iOS 18.2, *) {
                    if EnvironmentValues().supportsImagePlayground {
                        button(for: .playground)
                    }
                }
            }
            Section {
                button(for: .altText)
                Menu {
                    ForEach(AvatarRating.allCases, id: \.self) { rating in
                        button(for: .rating(rating), isSelected: rating == avatar.rating)
                    }
                } label: {
                    label(forAction: AvatarAction.rating(avatar.rating))
                }
            }
            Section {
                button(for: .delete)
            }
        } label: {
            ellipsisView()
        }
    }

    private func button(
        for action: AvatarAction,
        isSelected selected: Bool = false,
        systemImageWhenSelected systemImage: String = "checkmark"
    ) -> some View {
        Button(role: action.role) {
            onActionTap(action)
        } label: {
            switch action {
            case .rating(let rating):
                let buttonTitle = "\(rating.rawValue) (\(rating.localizedSubtitle))"

                if selected {
                    label(forAction: action, title: buttonTitle, systemImage: systemImage)
                } else {
                    Text(buttonTitle)
                }
            case .altText, .delete, .playground, .share:
                label(forAction: action)
            }
        }
    }

    private func label(forAction action: AvatarAction, title: String? = nil, systemImage: String) -> Label<Text, Image> {
        label(forAction: action, title: title, image: Image(systemName: systemImage))
    }

    private func label(forAction action: AvatarAction, title: String? = nil, image: Image? = nil) -> Label<Text, Image> {
        Label {
            Text(title ?? action.localizedTitle)
        } icon: {
            image ?? action.icon
        }
    }
}

extension AvatarRating {
    fileprivate var localizedSubtitle: String {
        switch self {
        case .g:
            SDKLocalizedString(
                "Avatar.Rating.G.subtitle",
                value: "General",
                comment: "Rating that indicates that the avatar is suitable for everyone"
            )
        case .pg:
            SDKLocalizedString(
                "Avatar.Rating.PG.subtitle",
                value: "Parental Guidance",
                comment: "Rating that indicates that the avatar may not be suitable for children"
            )
        case .r:
            SDKLocalizedString(
                "Avatar.Rating.R.subtitle",
                value: "Restricted",
                comment: "Rating that indicates that the avatar may not be suitable for children"
            )
        case .x:
            SDKLocalizedString(
                "Avatar.Rating.X.subtitle",
                value: "Extreme",
                comment: "Rating that indicates that the avatar is obviously and extremely unsuitable for children"
            )
        }
    }
}

#Preview {
    let avatar = AvatarImageModel.preview_init(
        id: "1",
        source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256"),
        rating: .pg
    )
    return AvatarPickerAvatarView(avatar: avatar, maxLength: AvatarGridConstants.maxAvatarWidth, minLength: AvatarGridConstants.minAvatarWidth) {
        false
    } onAvatarTap: { _ in
    } onFailedUploadTapped: { _ in
    } onActionTap: { _ in
    }
}
