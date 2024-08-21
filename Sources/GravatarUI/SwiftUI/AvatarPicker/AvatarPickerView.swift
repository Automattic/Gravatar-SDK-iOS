import Gravatar
import SwiftUI

@MainActor
struct AvatarPickerView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = .DS.Padding.double
        static let padding: EdgeInsets = .init(
            top: .DS.Padding.double,
            leading: horizontalPadding,
            bottom: .DS.Padding.double,
            trailing: horizontalPadding
        )
        static let lightModeShadowColor = Color(uiColor: UIColor.rgba(25, 30, 35, alpha: 0.2))
    }

    @ObservedObject var model: AvatarPickerViewModel

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    public var body: some View {
        ZStack {
            VStack {
                profileView()
                ScrollView {
                    errorView()
                    if !model.grid.isEmpty {
                        header()
                        AvatarGrid(
                            grid: model.grid,
                            onAvatarTap: { avatar in
                                model.selectAvatar(with: avatar.id)
                            },
                            onImageSelected: { image in
                                uploadImage(image)
                            },
                            onRetryUpload: { avatar in
                                retryUpload(avatar)
                            }
                        ).padding(Constants.padding)
                    } else if model.isAvatarsLoading {
                        avatarsLoadingView()
                    }
                }
                .onAppear() {
                    model.refresh()
                }
                if model.grid.isEmpty == false {
                    imagePicker {
                        CTAButtonView("Upload image")
                    }
                    .padding(Constants.padding)
                }
            }

            ToastContainerView(toastManager: model.toastManager)
                .padding(.horizontal, Constants.horizontalPadding * 2)
        }
    }

    private func header() -> some View {
        VStack(alignment: .leading) {
            Text("Avatars")
                .font(.title2.weight(.bold))
            Text("Choose or upload your favorite avatar images and connect them to your email address.")
                .font(.subheadline)
        }
        .padding(.init(top: .DS.Padding.double, leading: Constants.horizontalPadding, bottom: .DS.Padding.half, trailing: Constants.horizontalPadding))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorView() -> some View {
        VStack(alignment: .center) {
            switch model.gridResponseStatus {
            case .success where model.grid.isEmpty:
                contentLoadingErrorView(
                    title: "Let's setup your avatar",
                    subtext: "Choose or upload your favorite avatar images and connect them to your email address.",
                    image: Image("setup-avatar-emoji", bundle: .module),
                    actionButton: {
                        imagePicker {
                            CTAButtonView("Upload image")
                        }
                    }
                )
            case .failure(APIError.responseError(reason: let reason)) where reason.httpStatusCode == HTTPStatus.unauthorized.rawValue:
                contentLoadingErrorView(
                    title: "Session expired",
                    subtext: "Session expired for security reasons. Please log in to update your Avatar.",
                    actionButton: {
                        Button {
                            // TODO: Log in
                        } label: {
                            CTAButtonView("Log in".localized)
                        }
                    }
                )
            case .failure:
                contentLoadingErrorView(
                    title: "Ooops",
                    subtext: "Something went wrong and we couldn’t connect to Gravatar servers.",
                    image: nil,
                    actionButton: {
                        Button {
                            model.refresh()
                        } label: {
                            CTAButtonView("Try again".localized)
                        }
                    }
                )
            default:
                EmptyView()
            }
        }
        .foregroundColor(.secondary)
    }

    private func contentLoadingErrorView(
        title: String,
        subtext: String,
        image: Image? = nil,
        actionButton: @escaping () -> some View
    ) -> some View {
        ContentLoadingErrorView(
            title: title.localized,
            subtext: subtext.localized,
            image: image,
            actionButton: actionButton,
            innerPadding: .init(
                top: .DS.Padding.double,
                leading: Constants.horizontalPadding,
                bottom: .DS.Padding.double,
                trailing: Constants.horizontalPadding
            )
        )
        .padding(.horizontal, Constants.horizontalPadding)
    }

    private func imagePicker(label: @escaping () -> some View) -> some View {
        SystemImagePickerView(label: label) { image in
            uploadImage(image)
        }
    }

    private func uploadImage(_ image: UIImage) {
        Task {
            await model.upload(image)
        }
    }

    private func retryUpload(_ avatar: AvatarImageModel) {
        Task {
            await model.retryUpload(of: avatar.id)
        }
    }

    private func avatarsLoadingView() -> some View {
        VStack {
            Spacer(minLength: .DS.Padding.large)

            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle()
                )
                .controlSize(.regular)
        }
    }

    @ViewBuilder
    private func profileView() -> some View {
        VStack(alignment: .leading, content: {
            AvatarPickerProfileView(
                avatarURL: $model.selectedAvatarURL,
                model: $model.profileModel,
                isLoading: $model.isProfileLoading
            ) { _ in
                // TODO: Handle the link
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.init(
                    top: .DS.Padding.single,
                    leading: Constants.horizontalPadding,
                    bottom: .DS.Padding.single,
                    trailing: Constants.horizontalPadding
                ))
                .background(profileBackground)
                .cornerRadius(8)
                .shadow(color: profileShadowColor, radius: profileShadowRadius, y: 3)
        })
        .padding(Constants.padding)
    }

    @ViewBuilder
    private var profileBackground: some View {
        if colorScheme == .dark {
            Color(UIColor.systemBackground).colorInvert().opacity(0.09)
        } else {
            Color(UIColor.systemBackground)
        }
    }

    private var profileShadowColor: Color {
        colorScheme == .light ? Constants.lightModeShadowColor : .clear
    }

    private var profileShadowRadius: CGFloat {
        colorScheme == .light ? 30 : 0
    }
}

#Preview("Existing elements") {
    struct PreviewModel: ProfileSummaryModel {
        var avatarIdentifier: Gravatar.AvatarIdentifier? {
            .email("xxx@gmail.com")
        }

        var displayName: String {
            "Shelly Kimbrough"
        }

        var jobTitle: String {
            "Payroll clerk"
        }

        var pronunciation: String {
            "shell-ee"
        }

        var pronouns: String {
            "she/her"
        }

        var location: String {
            "San Antonio, TX"
        }

        var profileURL: URL? {
            URL(string: "https://gravatar.com")
        }

        var profileEditURL: URL? {
            URL(string: "https://gravatar.com")
        }
    }

    let model = AvatarPickerViewModel(
        avatarImageModels: [
            .init(id: "0", source: .local(image: UIImage()), isLoading: true),
            .init(id: "1", source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256")),
            .init(id: "2", source: .remote(url: "https://gravatar.com/userimage/110207384/db73834576b01b69dd8da1e29877ca07.jpeg?size=256")),
            .init(id: "3", source: .remote(url: "https://gravatar.com/userimage/110207384/3f7095bf2580265d1801d128c6410016.jpeg?size=256")),
            .init(id: "4", source: .remote(url: "https://gravatar.com/userimage/110207384/fbbd335e57862e19267679f19b4f9db8.jpeg?size=256")),
            .init(id: "5", source: .remote(url: "https://gravatar.com/userimage/110207384/96c6950d6d8ce8dd1177a77fe738101e.jpeg?size=256")),
            .init(id: "6", source: .remote(url: "https://gravatar.com/userimage/110207384/4a4f9385b0a6fa5c00342557a098f480.jpeg?size=256")),
            .init(id: "7", source: .local(image: UIImage()), uploadHasFailed: true),
        ],
        selectedImageID: "5",
        profileModel: PreviewModel()
    )

    return AvatarPickerView(model: model)
}

#Preview("Empty elements") {
    AvatarPickerView(model: .init(avatarImageModels: [], profileModel: nil))
}

#Preview("Load from network") {
    /// Enter valid email and auth token.
    AvatarPickerView(model: .init(email: .init(""), authToken: ""))
}
