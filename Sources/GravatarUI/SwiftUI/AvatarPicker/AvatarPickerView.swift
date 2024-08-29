import Gravatar
import SwiftUI

public enum AvatarPickerContentLayout: String, CaseIterable, Identifiable {
    public var id: Self { self }

    case vertical
    case horizontal
}

@MainActor
struct AvatarPickerView<ImageEditor: ImageEditorView>: View {
    fileprivate typealias Constants = AvatarPicker.Constants
    fileprivate typealias Localized = AvatarPicker.Localized

    @ObservedObject var model: AvatarPickerViewModel
    @State var contentLayout: AvatarPickerContentLayout = .vertical
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Binding var isPresented: Bool
    @State private var safariURL: URL?
    var customImageEditor: ImageEditorBlock<ImageEditor>?
    var tokenErrorHandler: (() -> Void)?

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                email()
                profileView()
                ScrollView {
                    errorView()
                    if !model.grid.isEmpty {
                        content()
                    } else if model.isAvatarsLoading {
                        avatarsLoadingView()
                    }
                    Spacer()
                        .frame(height: Constants.vStackVerticalSpacing)
                }
                .task {
                    model.refresh()
                }
            }

            ToastContainerView(toastManager: model.toastManager)
                .padding(.horizontal, Constants.horizontalPadding * 2)
        }
        .gravatarNavigation(
            title: Constants.title,
            actionButtonDisabled: model.profileModel?.profileURL == nil,
            onActionButtonPressed: {
                openProfileInSafari()
            },
            onDoneButtonPressed: {
                isPresented = false
            }
        )
        .fullScreenCover(item: $safariURL) { url in
            SafariView(url: url)
                .edgesIgnoringSafeArea(.all)
        }
    }

    @ViewBuilder
    private func email() -> some View {
        if let email = model.email?.rawValue, !email.isEmpty {
            Text(email)
                .padding(.bottom, Constants.emailBottomSpacing / 2)
                .font(.footnote)
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
    }

    private func header() -> some View {
        VStack(alignment: .leading) {
            Text(Localized.Header.title)
                .font(.title2.weight(.bold))
            Text(Localized.Header.subtitle)
                .font(.subheadline)
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding(.init(top: .DS.Padding.double, leading: Constants.horizontalPadding, bottom: .DS.Padding.half, trailing: Constants.horizontalPadding))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func errorView() -> some View {
        VStack(alignment: .center) {
            switch model.gridResponseStatus {
            case .success where model.grid.isEmpty:
                contentLoadingErrorView(
                    title: Localized.ContentLoading.Success.title,
                    subtext: Localized.ContentLoading.Success.subtext,
                    image: Image("setup-avatar-emoji", bundle: .module),
                    actionButton: {
                        imagePicker {
                            CTAButtonView(Localized.buttonUploadImage)
                        }
                    }
                )
            case .failure(APIError.responseError(reason: let reason)) where reason.httpStatusCode == HTTPStatus.unauthorized.rawValue:
                let buttonTitle = tokenErrorHandler == nil ?
                    Localized.ContentLoading.Failure.SessionExpired.Close.buttonTitle :
                    Localized.ContentLoading.Failure.SessionExpired.LogIn.buttonTitle
                let subtext: String = tokenErrorHandler == nil ?
                    Localized.ContentLoading.Failure.SessionExpired.Close.subtext :
                    Localized.ContentLoading.Failure.SessionExpired.LogIn.subtext
                contentLoadingErrorView(
                    title: Localized.ContentLoading.Failure.SessionExpired.title,
                    subtext: subtext,
                    actionButton: {
                        Button {
                            if let tokenErrorHandler {
                                tokenErrorHandler()
                            } else {
                                isPresented = false
                            }
                        } label: {
                            CTAButtonView(buttonTitle)
                        }
                    }
                )
            case .failure:
                contentLoadingErrorView(
                    title: Localized.ContentLoading.Failure.Retry.title,
                    subtext: Localized.ContentLoading.Failure.Retry.subtext,
                    image: nil,
                    actionButton: {
                        Button {
                            model.refresh()
                        } label: {
                            CTAButtonView(Localized.buttonRetry)
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
        SystemImagePickerView(label: label, customEditor: customImageEditor) { image in
            uploadImage(image)
        }
    }

    private func uploadImage(_ image: UIImage) {
        Task {
            // If there's a custom image editor, it should take care of squaring.
            await model.upload(image, shouldSquareImage: customImageEditor == nil)
        }
    }

    private func retryUpload(_ avatar: AvatarImageModel) {
        Task {
            await model.retryUpload(of: avatar.id)
        }
    }

    @ViewBuilder
    private func avatarGrid() -> some View {
        if contentLayout == .vertical {
            AvatarGrid(
                grid: model.grid,
                customImageEditor: customImageEditor,
                onAvatarTap: { avatar in
                    model.selectAvatar(with: avatar.id)
                },
                onImagePickerDidPickImage: { image in
                    uploadImage(image)
                },
                onRetryUpload: { avatar in
                    retryUpload(avatar)
                }
            )
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.vertical, .DS.Padding.medium)
        } else {
            HorizontalAvatarGrid(
                grid: model.grid,
                onAvatarTap: { avatar in
                    model.selectAvatar(with: avatar.id)
                },
                onRetryUpload: { avatar in
                    retryUpload(avatar)
                }
            )
            .padding(.top, .DS.Padding.medium)
            .padding(.bottom, .DS.Padding.double)
            imagePicker {
                CTAButtonView("Upload image")
            }
            .padding(.horizontal, Constants.horizontalPadding)
            .padding(.bottom, .DS.Padding.medium)
        }
    }

    private func content() -> some View {
        VStack(spacing: 0) {
            header()
            avatarGrid()
        }
        .avatarPickerBorder(colorScheme: colorScheme)
        .padding(.horizontal, Constants.horizontalPadding)
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

    private func openProfileInSafari() {
        safariURL = model.profileModel?.profileURL
    }

    @ViewBuilder
    private func profileView() -> some View {
        VStack(alignment: .leading, content: {
            AvatarPickerProfileView(
                avatarURL: $model.selectedAvatarURL,
                model: $model.profileModel,
                isLoading: $model.isProfileLoading
            ) {
                openProfileInSafari()
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
        .padding(.top, Constants.emailBottomSpacing / 2)
        .padding(.bottom, Constants.vStackVerticalSpacing)
        .padding(.horizontal, Constants.horizontalPadding)
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

private enum AvatarPicker {
    enum Constants {
        static let horizontalPadding: CGFloat = .DS.Padding.double
        static let lightModeShadowColor = Color(uiColor: UIColor.rgba(25, 30, 35, alpha: 0.2))
        static let title: String = "Gravatar" // defined here to avoid translations
        static let vStackVerticalSpacing: CGFloat = .DS.Padding.medium
        static let emailBottomSpacing: CGFloat = .DS.Padding.double
    }

    enum Localized {
        static let buttonUploadImage = NSLocalizedString(
            "AvatarPicker.ContentLoading.Success.ctaButtonTitle",
            value: "Upload image",
            comment: "Title of a button that allow for uploading an image"
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
                        comment: "Title of a message advising the user that their login session has expired."
                    )
                    enum Close {
                        static let buttonTitle = NSLocalizedString(
                            "AvatarPicker.ContentLoading.Failure.SessionExpired.Close.buttonTitle",
                            value: "Close",
                            comment: "Title of a button that will close the Avatar Picker, appearing beneath a message that advises the user that their login session has expired."
                        )

                        static let subtext = NSLocalizedString(
                            "AvatarPicker.ContentLoading.Failure.SessionExpired.Close.subtext",
                            value: "Sorry, it looks like your session has expired. Make sure you're logged in to update your Avatar.",
                            comment: "A message describing the error and advising the user to login again to resolve the issue"
                        )
                    }

                    enum LogIn {
                        static let buttonTitle = NSLocalizedString(
                            "AvatarPicker.ContentLoading.Failure.SessionExpired.LogIn.buttonTitle",
                            value: "Log in",
                            comment: "Title of a button that will begin the process of authenticating the user, appearing beneath a message that advises the user that their login session has expired."
                        )
                        static let subtext = NSLocalizedString(
                            "AvatarPicker.ContentLoading.Failure.SessionExpired.LogIn.subtext",
                            value: "Session expired for security reasons. Please log in to update your Avatar.",
                            comment: "A message describing the error and advising the user to login again to resolve the issue"
                        )
                    }
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

    return AvatarPickerView<NoCustomEditor>(model: model, contentLayout: .horizontal, isPresented: .constant(true))
}

#Preview("Empty elements") {
    AvatarPickerView<NoCustomEditor>(model: .init(avatarImageModels: [], profileModel: nil), isPresented: .constant(true))
}

#Preview("Load from network") {
    /// Enter valid email and auth token.
    AvatarPickerView<NoCustomEditor>(model: .init(email: .init(""), authToken: ""), isPresented: .constant(true))
}
