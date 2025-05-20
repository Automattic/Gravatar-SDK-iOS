import Foundation
import SwiftUI

struct AvatarPickerProfileViewWrapper: View {
    enum ButtonsMode {
        case avatar
        case aboutInfo
    }

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @Binding var avatarID: AvatarIdentifier?
    @Binding var forceRefreshAvatar: Bool
    @Binding var model: AvatarPickerProfileViewModel?
    @Binding var isLoading: Bool
    @Binding var safariURL: IdentifiableURL?
    @Binding var buttonsMode: ButtonsMode?
    var buttonTapHandler: ((ButtonsMode) -> Void)? = nil

    public var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                AvatarPickerProfileView(
                    avatarID: $avatarID,
                    forceRefreshAvatar: $forceRefreshAvatar,
                    model: $model,
                    isLoading: $isLoading,
                    avatarAccessoryView: {
                        if case .avatar = buttonsMode {
                            editButton {
                                buttonTapHandler?(.avatar)
                            }
                        } else {
                            EmptyView()
                        }
                    }
                ) {
                    safariURL = IdentifiableURL(url: model?.profileURL)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.init(
                    top: .DS.Padding.single,
                    leading: AvatarPicker.Constants.horizontalPadding,
                    bottom: .DS.Padding.single,
                    trailing: AvatarPicker.Constants.horizontalPadding
                ))
                .background(profileBackground)
                .cornerRadius(8)
                if case .aboutInfo = buttonsMode {
                    editButton {
                        buttonTapHandler?(.aboutInfo)
                    }.padding()
                }
            }
        }
        .shadow(color: profileShadowColor, radius: profileShadowRadius, y: 3)
    }

    @ViewBuilder
    private var profileBackground: some View {
        if colorScheme == .dark {
            Color(UIColor.secondarySystemBackground)
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

    @ViewBuilder
    private func editButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image("pencil", bundle: Bundle.module)
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundColor(.black)
                .padding(6)
                .background(Color.white)
                .clipShape(Circle())
        }
    }
}

#Preview {
    AvatarPickerProfileViewWrapper(
        avatarID: .constant(nil),
        forceRefreshAvatar: .constant(false),
        model: .constant(nil),
        isLoading: .constant(false),
        safariURL: .constant(nil),
        buttonsMode: .constant(.none)
    )
}

#Preview("Edit info button") {
    AvatarPickerProfileViewWrapper(
        avatarID: .constant(nil),
        forceRefreshAvatar: .constant(false),
        model: .constant(nil),
        isLoading: .constant(false),
        safariURL: .constant(nil),
        buttonsMode: .constant(.aboutInfo)
    )
}

#Preview("Avatar button") {
    AvatarPickerProfileViewWrapper(
        avatarID: .constant(nil),
        forceRefreshAvatar: .constant(false),
        model: .constant(nil),
        isLoading: .constant(false),
        safariURL: .constant(nil),
        buttonsMode: .constant(.avatar)
    )
}
