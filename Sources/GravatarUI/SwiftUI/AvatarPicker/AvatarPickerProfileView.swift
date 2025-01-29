import Gravatar
import SwiftUI

@MainActor
struct AvatarPickerProfileView: View {
    private enum Constants {
        static let avatarLength: CGFloat = 72
    }

    struct Model {
        var displayName: String
        var location: String
        var profileURL: URL?

        var profileDetails: String? {
            location.nilIfEmpty()
        }
    }

    @Binding var avatarID: AvatarIdentifier?
    @Binding var isEditModeAvatar: Bool

    private var avatarURL: URL? {
        guard let avatarID else { return nil }
        return AvatarURL(
            with: avatarID,
            options: .init(
                preferredSize: .points(Constants.avatarLength),
                rating: .x,
                defaultAvatarOption: .status404
            )
        )?.url
    }

    @Binding var forceRefreshAvatar: Bool
    @Binding var model: Model?
    @Binding var isLoading: Bool
    @StateObject private var placeholderColorManager: ProfileViewPlaceholderColorManager = .init()
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    private(set) var viewProfileAction: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .center, spacing: .DS.Padding.single) {
                avatarView()
                if model == nil && isLoading {
                    emptyViews()
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(model?.displayName ?? Localized.namePlaceholder)
                            .font(.headline)
                            .fontWeight(.bold)
                        if let model {
                            if let details = model.profileDetails {
                                secondaryText(text: details)
                            }
                            Button(Localized.viewProfileButtonTitle) {
                                viewProfileAction?()
                            }
                            .font(.footnote)
                            .foregroundColor(Color(UIColor.label))
                            .padding(.init(top: .DS.Padding.half, leading: 0, bottom: 0, trailing: 0))
                        } else {
                            secondaryText(text: Localized.profileDetailsPlaceholder)
                        }
                    }
                }
                Spacer()
            }
            // .background(Color.blue)
            .onChange(of: isLoading) { newValue in
                placeholderColorManager.toggleAnimation(newValue)
            }
            .onChange(of: colorScheme) { newValue in
                placeholderColorManager.colorScheme = newValue
            }
            .onAppear {
                placeholderColorManager.colorScheme = colorScheme
                placeholderColorManager.toggleAnimation(isLoading)
            }
            if isEditModeAvatar {
                HStack {
                    // Spacer()
                    Button {
                        isEditModeAvatar = false
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .aspectRatio(contentMode: .fit)
                            .padding(.vertical, 0)
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }

    private func secondaryText(text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(Color(UIColor.secondaryLabel))
    }

    func emptyViews() -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.half, content: {
            RoundedRectangle(cornerRadius: 12)
                .frame(width: 180, height: 24)
            RoundedRectangle(cornerRadius: 6)
                .frame(width: 100, height: 12)
            RoundedRectangle(cornerRadius: 6)
                .frame(width: 140, height: 12)
        })
        .foregroundColor(placeholderColorManager.placeholderColor)
    }

    func avatarView() -> some View {
        ZStack(alignment: .bottomTrailing) {
            AvatarView(
                url: avatarURL,
                placeholderView: {
                    Image("qe-intro-empty-profile-avatar", bundle: .module)
                        .colorScheme(colorScheme)
                        .background(Color(UIColor.systemBackground))
                },
                oneTimeForceRefresh: $forceRefreshAvatar,
                loadingView: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            )
            .scaledToFill()
            .frame(width: Constants.avatarLength, height: Constants.avatarLength)
            .background(placeholderColorManager.placeholderColor)
            .aspectRatio(1, contentMode: .fill)
            .shape(Circle())
            // .background(Color(UIColor.blue))

            if !isEditModeAvatar {
                Button {
                    isEditModeAvatar = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .aspectRatio(contentMode: .fit)
                        // .padding()
                        .foregroundColor(.black)
                        .background(.white)
                }
            }
        }
    }

    private var paletteType: PaletteType? {
        switch colorScheme {
        case .light:
            .light
        case .dark:
            .dark
        @unknown default:
            nil
        }
    }
}

// MARK: - Localized Strings

extension AvatarPickerProfileView {
    private enum Localized {
        static let viewProfileButtonTitle = SDKLocalizedString(
            "AvatarPickerProfile.Button.ViewProfile.title1",
            value: "Edit profile →",
            comment: "Title of a button that will take you to your Gravatar profile, with an arrow indicating that this action will cause you to leave this view"
        )
        static let namePlaceholder = SDKLocalizedString(
            "AvatarPickerProfile.Name.placeholder",
            value: "Your Name",
            comment: "Placeholder text for the name field"
        )
        static let profileDetailsPlaceholder = SDKLocalizedString(
            "AvatarPickerProfile.ProfileFields.placeholder",
            value: "Location",
            comment: "Placeholder text for the profile card. Will show as subtitle bellow the name placeholder."
        )
    }
}

// MARK: - Previews

#Preview {
    ZStack(alignment: .topTrailing) {
        AvatarPickerProfileView(
            avatarID: .constant(.email("email@domain.com")),
            isEditModeAvatar: .constant(false),
            forceRefreshAvatar: .constant(false),
            model: .constant(
                .init(
                    displayName: "Shelly Kimbrough",
                    location: "San Antonio, TX",
                    profileURL: URL(string: "https://gravatar.com")
                )
            ),
            isLoading: .constant(false)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        // .background(Color.accentColor.opacity(0.05))
        /*  Button {

         } label: {
         Image(systemName: "square.and.pencil")
         .resizable()
         .frame(width: 16, height: 16)
         .aspectRatio(contentMode: .fit)
         .padding()
         .foregroundColor(.black)
         }*/
    }
}

#Preview("Empty") {
    HStack {
        AvatarPickerProfileView(
            avatarID: .constant(.email("email@domain.com")),
            isEditModeAvatar: .constant(false),
            forceRefreshAvatar: .constant(false),
            model: .constant(nil),
            isLoading: .constant(false)
        )
    }
}

#Preview("Empty & Loading") {
    AvatarPickerProfileView(
        avatarID: .constant(.email("email@domain.com")),
        isEditModeAvatar: .constant(false),
        forceRefreshAvatar: .constant(false),
        model: .constant(nil),
        isLoading: .constant(true)
    )
}
