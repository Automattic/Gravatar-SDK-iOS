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
                .task {
                    model.refresh()
                }
                if model.grid.isEmpty == false {
                    imagePicker {
                        CTAButtonView(TextContent.buttonUploadImage)
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
            Text(TextContent.Header.title)
                .font(.title2.weight(.bold))
            Text(TextContent.Header.subtitle)
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
                    title: TextContent.ContentLoading.Success.title,
                    subtext: TextContent.ContentLoading.Success.subtext,
                    image: Image("setup-avatar-emoji", bundle: .module),
                    actionButton: {
                        imagePicker {
                            CTAButtonView(TextContent.buttonUploadImage)
                        }
                    }
                )
            case .failure(APIError.responseError(reason: let reason)) where reason.httpStatusCode == HTTPStatus.unauthorized.rawValue:
                contentLoadingErrorView(
                    title: TextContent.ContentLoading.Failure.SessionExpired.title,
                    subtext: TextContent.ContentLoading.Failure.SessionExpired.subtext,
                    actionButton: {
                        Button {
                            // TODO: Log in
                        } label: {
                            CTAButtonView(TextContent.buttonLogin)
                        }
                    }
                )
            case .failure:
                contentLoadingErrorView(
                    title: TextContent.ContentLoading.Failure.Retry.title,
                    subtext: TextContent.ContentLoading.Failure.Retry.subtext,
                    image: nil,
                    actionButton: {
                        Button {
                            model.refresh()
                        } label: {
                            CTAButtonView(TextContent.buttonRetry)
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
            title: title,
            subtext: subtext,
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

// MARK: - Localized Strings

private enum TextContent {
    static let buttonUploadImage = NSLocalizedString(
        "AvatarPicker.ContentLoading.Success.ctaButtonTitle",
        value: "Upload image",
        comment: "Title of a button that allow for uploading an image"
    )
    static let buttonLogin = NSLocalizedString(
        "AvatarPicker.ContentLoading.Failure.SessionExpired.ctaButtonTitle",
        value: "Login",
        comment: "Title of a button that allows the user to log in"
    )
    static let buttonRetry = NSLocalizedString(
        "AvatarPicker.ContentLoading.Failure.Retry.ctaButtonTitle",
        value: "Try again",
        comment: "Title of a button that allows the user to try loading their avatars again"
    )

    enum Header {
        static let title = NSLocalizedString(
            "AvatarPicker.Header.title",
            value: "Avatars",
            comment: "Title appearing in the header of a view that allows users to manage their avatars"
        )
        static let subtitle = NSLocalizedString(
            "AvatarPicker.Header.subtitle",
            value: "Choose or upload your favorite avatar images and connect them to your email address.",
            comment: "A message describing the purpose of this view"
        )
    }

    enum ContentLoading {
        enum Success {
            static let title = NSLocalizedString(
                "AvatarPicker.ContentLoading.success.title",
                value: "Let's setup your avatar",
                comment: "Title of a message advising the user to setup their avatar"
            )
            static let subtext = NSLocalizedString(
                "AvatarPicker.ContentLoading.Success.subtext",
                value: "Choose or upload your favorite avatar images and connect them to your email address.",
                comment: "A message describing the actions a user can take to setup their avatar"
            )
        }

        enum Failure {
            enum SessionExpired {
                static let title = NSLocalizedString(
                    "AvatarPicker.ContentLoading.Failure.SessionExpired.title",
                    value: "Session expired",
                    comment: "Title of a message advising the user that their login session has expired"
                )
                static let subtext = NSLocalizedString(
                    "AvatarPicker.ContentLoading.Failure.SessionExpired.subtext",
                    value: "Session expired for security reasons. Please log in to update your Avatar.",
                    comment: "A message describing the error and advising the user to login again to resolve the issue"
                )
            }

            enum Retry {
                static let title = NSLocalizedString(
                    "AvatarPicker.ContentLoading.Failure.Retry.title",
                    value: "Ooops",
                    comment: "Title of a message advising the user that something went wrong while loading their avatars"
                )
                static let subtext = NSLocalizedString(
                    "AvatarPicker.ContentLoading.Failure.Retry.subtext",
                    value: "Something went wrong and we couldn’t connect to Gravatar servers.",
                    comment: "A message asking the user to try again"
                )
            }
        }
    }
}

// MARK: - Previews

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
