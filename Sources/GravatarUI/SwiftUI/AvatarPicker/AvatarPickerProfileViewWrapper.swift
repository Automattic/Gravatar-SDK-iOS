import Foundation
import SwiftUI

struct AvatarPickerProfileViewWrapper: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var avatarID: AvatarIdentifier?
    @Binding var forceRefreshAvatar: Bool
    @Binding var model: AvatarPickerProfileView.Model?
    @Binding var isLoading: Bool
    @Binding var safariURL: IdentifiableURL?
    @Binding var isEditModeAvatar: Bool

    public var body: some View {
        VStack(alignment: .leading, content: {
            AvatarPickerProfileView(
                avatarID: $avatarID,
                isEditModeAvatar: $isEditModeAvatar,
                forceRefreshAvatar: $forceRefreshAvatar,
                model: $model,
                isLoading: $isLoading
            ) {
                safariURL = IdentifiableURL(url: model?.profileURL)
            }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.init(
                    top: .DS.Padding.single,
                    leading: AvatarPicker.Constants.horizontalPadding,
                    bottom: .DS.Padding.single,
                    trailing: AvatarPicker.Constants.horizontalPadding
                ))
                .background(profileBackground)
                .cornerRadius(8)
                .shadow(color: profileShadowColor, radius: profileShadowRadius, y: 3)
        })
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
        colorScheme == .light ? AvatarPicker.Constants.lightModeShadowColor : .clear
    }

    private var profileShadowRadius: CGFloat {
        colorScheme == .light ? 30 : 0
    }
}
