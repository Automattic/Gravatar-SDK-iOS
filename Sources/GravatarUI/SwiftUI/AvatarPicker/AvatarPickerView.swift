import Gravatar
import SwiftUI

@MainActor
struct AvatarPickerView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = .DS.Padding.double
        static let maxAvatarWidth: CGFloat = 100
        static let minAvatarWidth: CGFloat = 80
        static let avatarSpacing: CGFloat = 20
        static let padding: EdgeInsets = .init(
            top: .DS.Padding.double,
            leading: horizontalPadding,
            bottom: .DS.Padding.double,
            trailing: horizontalPadding
        )
        static let selectedBorderWidth: CGFloat = .DS.Padding.half
        static let avatarCornerRadius: CGFloat = .DS.Padding.single
    }

    @StateObject var model: AvatarPickerViewModel

    init(model: AvatarPickerViewModel) {
        _model = StateObject(wrappedValue: model)
    }

    public var body: some View {
        VStack {
            profileView()
            ScrollView {
                errorView()

                if case .success(let avatarImageModels) = model.avatarsResult,
                   !avatarImageModels.isEmpty
                {
                    header()
                    avatarGrid(with: avatarImageModels)
                } else if model.isAvatarsLoading {
                    avatarsLoadingView()
                }
            }
            .task {
                model.refresh()
            }
            if model.avatarsResult?.value()?.isEmpty == false {
                imagePicker {
                    CTAButtonView("Upload image")
                }
                .padding(Constants.padding)
            }
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
            switch model.avatarsResult {
            case .success(let models) where models.isEmpty:
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
            Task {
                await model.upload(image)
            }
        }
    }

    @ViewBuilder
    private func avatarGrid(with avatarImageModels: [AvatarImageModel]) -> some View {
        let gridItems = [GridItem(
            .adaptive(
                minimum: Constants.minAvatarWidth,
                maximum: Constants.maxAvatarWidth
            ),
            spacing: Constants.avatarSpacing
        )]

        LazyVGrid(columns: gridItems, spacing: Constants.avatarSpacing) {
            imagePicker {
                PlusButtonView(minSize: Constants.minAvatarWidth, maxSize: Constants.maxAvatarWidth)
            }

            ForEach(avatarImageModels) { avatar in
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
                    borderWidth: model.currentAvatarResult?.value() == avatar.id ? Constants.selectedBorderWidth : 0
                )
                .overlay {
                    if case .local = avatar.source, avatar.isLoading {
                        OverlayActivityIndicatorView()
                            .cornerRadius(Constants.avatarCornerRadius)
                    }
                }
            }
        }
        .padding(Constants.padding)
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
                avatarIdentifier: $model.avatarIdentifier,
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
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 10)
        })
        .padding(Constants.padding)
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

    return AvatarPickerView(model: .init(
        avatarImageModels: [
            .init(id: "0", source: .local(image: UIImage()), isLoading: true),
            .init(id: "1", source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256")),
            .init(id: "2", source: .remote(url: "https://gravatar.com/userimage/110207384/db73834576b01b69dd8da1e29877ca07.jpeg?size=256")),
            .init(id: "3", source: .remote(url: "https://gravatar.com/userimage/110207384/3f7095bf2580265d1801d128c6410016.jpeg?size=256")),
            .init(id: "4", source: .remote(url: "https://gravatar.com/userimage/110207384/fbbd335e57862e19267679f19b4f9db8.jpeg?size=256")),
            .init(id: "5", source: .remote(url: "https://gravatar.com/userimage/110207384/96c6950d6d8ce8dd1177a77fe738101e.jpeg?size=256")),
            .init(id: "6", source: .remote(url: "https://gravatar.com/userimage/110207384/4a4f9385b0a6fa5c00342557a098f480.jpeg?size=256")),
        ],
        selectedImageID: "5",
        profileModel: PreviewModel()
    ))
}

#Preview("Empty elements") {
    AvatarPickerView(model: .init(avatarImageModels: [], profileModel: nil))
}

#Preview("Load from network") {
    /// Enter valid email and auth token.
    AvatarPickerView(model: .init(email: .init(""), authToken: ""))
}
