import Gravatar
import SwiftUI

@MainActor
struct AvatarPickerProfileView<AccessoryView>: View where AccessoryView: View {
    @Binding var avatarID: AvatarIdentifier?
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
    @Binding var model: AvatarPickerProfileViewModel?
    @Binding var isLoading: Bool
    @StateObject private var placeholderColorManager: ProfileViewPlaceholderColorManager = .init()
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var avatarAccessoryView: () -> AccessoryView

    private(set) var viewProfileAction: (() -> Void)? = nil

    init(
        avatarID: Binding<AvatarIdentifier?>,
        forceRefreshAvatar: Binding<Bool>,
        model: Binding<AvatarPickerProfileViewModel?>,
        isLoading: Binding<Bool>,
        @ViewBuilder avatarAccessoryView: @escaping () -> AccessoryView,
        viewProfileAction: (() -> Void)? = nil
    ) {
        self._avatarID = avatarID
        self._forceRefreshAvatar = forceRefreshAvatar
        self._model = model
        self._isLoading = isLoading
        self.avatarAccessoryView = avatarAccessoryView
        self.viewProfileAction = viewProfileAction
    }

    var body: some View {
        HStack(alignment: .center, spacing: .DS.Padding.single) {
            ZStack(alignment: .bottomTrailing) {
                avatarView()
                avatarAccessoryView()
                    .zIndex(1)
            }

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
        }
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
        .accessibilityLabel(Localized.avatarAccessibilityLabel)
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

struct AvatarPickerProfileViewModel {
    var displayName: String
    var location: String
    var profileURL: URL?

    var profileDetails: String? {
        location.nilIfEmpty()
    }
}

private enum Constants {
    static let avatarLength: CGFloat = 72
}

// MARK: - Localized Strings

private enum Localized {
    static let viewProfileButtonTitle = SDKLocalizedString(
        "AvatarPickerProfile.Button.ViewProfile.title",
        value: "View profile →",
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
    static let avatarAccessibilityLabel = SDKLocalizedString(
        "AvatarPickerProfile.ProfileFields.avatarAccessibilityLabel",
        value: "Your avatar",
        comment: "VoiceOver readout for the avatar image in the profile card."
    )
}

// MARK: - Previews

#Preview {
    AvatarPickerProfileView(
        avatarID: .constant(.email("email@domain.com")),
        forceRefreshAvatar: .constant(false),
        model: .constant(
            .init(
                displayName: "Shelly Kimbrough",
                location: "San Antonio, TX",
                profileURL: URL(string: "https://gravatar.com")
            )
        ),
        isLoading: .constant(false),
        avatarAccessoryView: { EmptyView() }
    )
}

#Preview("Scope Switch") {
    AvatarPickerProfileView(
        avatarID: .constant(.email("email@domain.com")),
        forceRefreshAvatar: .constant(false),
        model: .constant(
            .init(
                displayName: "Shelly Kimbrough",
                location: "San Antonio, TX",
                profileURL: URL(string: "https://gravatar.com")
            )
        ),
        isLoading: .constant(false),
        avatarAccessoryView: { EmptyView() }
    )
}

#Preview("Empty") {
    AvatarPickerProfileView(
        avatarID: .constant(.email("email@domain.com")),
        forceRefreshAvatar: .constant(false),
        model: .constant(nil),
        isLoading: .constant(false),
        avatarAccessoryView: { EmptyView() }
    )
}

#Preview("Empty & Loading") {
    AvatarPickerProfileView(
        avatarID: .constant(.email("email@domain.com")),
        forceRefreshAvatar: .constant(false),
        model: .constant(nil),
        isLoading: .constant(true),
        avatarAccessoryView: { EmptyView() }
    )
}
