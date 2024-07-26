import Gravatar
import SwiftUI

@MainActor
struct AvatarPickerView: View {
    enum Constants {
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
        static let errorPadding: EdgeInsets = .init(
            top: .DS.Padding.double,
            leading: horizontalPadding * 2,
            bottom: .DS.Padding.double,
            trailing: horizontalPadding * 2
        )
        static let selectedBorderWidth: CGFloat = .DS.Padding.half
        static let avatarCornerRadius: CGFloat = .DS.Padding.single
    }

    @StateObject var model: AvatarPickerViewModel

    var body: some View {
        ScrollView {
            header()
            errorMessages()

            profileView()

            if case .success(let avatarImageModels) = model.avatarsResult {
                avatarGrid(with: avatarImageModels)
            } else if model.isAvatarsLoading {
                avatarsLoadingView()
            }
        }
        .task {
            model.refresh()
        }
    }

    @ViewBuilder
    private func header() -> some View {
        VStack(alignment: .leading) {
            Text("Avatars").font(.largeTitle.weight(.bold))
            Text("Upload or create your favorite avatar images and connect them to your email address.").font(.footnote)
        }
        .padding(.init(top: .DS.Padding.double, leading: Constants.horizontalPadding, bottom: .DS.Padding.half, trailing: Constants.horizontalPadding))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func errorMessages() -> some View {
        VStack(alignment: .center) {
            switch model.avatarsResult {
            case .success(let models) where models.isEmpty:
                errorText("You don't have any avatars yet. Why not start uploading some now?")
            case .failure:
                Spacer(minLength: .DS.Padding.large * 2)
                errorText("Sorry, it seems like something didn't quite work out when getting your avatars.")
                tryAgainButton()
            default:
                EmptyView()
            }
        }
        .foregroundColor(.secondary)
    }

    @ViewBuilder
    private func tryAgainButton() -> some View {
        Button(action: {
            model.refresh()
        }, label: {
            VStack {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .scaledToFit()
                    .font(.largeTitle)
                    .frame(width: .DS.Padding.medium)

                Spacer()
                Text("Try Again")
                    .font(.subheadline)
            }
        })
    }

    private func errorText(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .padding(Constants.errorPadding)
            .multilineTextAlignment(.center)
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
            ForEach(avatarImageModels) { avatar in
                AvatarView(
                    url: avatar.url,
                    placeholder: nil,
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
            }
        }
        .padding(Constants.padding)
    }

    @ViewBuilder
    private func avatarsLoadingView() -> some View {
        VStack {
            switch model.avatarsResult {
            case .failure:
                Spacer(minLength: .DS.Padding.large * 2)
            default:
                Spacer(minLength: .DS.Padding.medium)
            }

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
                .cornerRadius(4)
                .shadow(radius: 10)
        })
        .padding(Constants.padding)
    }
}

#Preview("Existing elements") {
    AvatarPickerView(model: .init(
        avatarImageModels: [
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

private struct PreviewModel: ProfileSummaryModel {
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
