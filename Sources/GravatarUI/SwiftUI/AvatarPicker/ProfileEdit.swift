import SwiftUI

@available(iOS 16.0, *)
struct ProfileEditView: View {
    @ObservedObject var model: AvatarPickerViewModel
    @Binding var safariURL: IdentifiableURL?
    @Binding var isEditModeAvatar: Bool

    @State private var name: String
    @State private var location: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @FocusState var isNameFocused: Bool

    init(model: AvatarPickerViewModel, safariURL: Binding<IdentifiableURL?>, isEditModeAvatar: Binding<Bool>) {
        self.model = model
        self._safariURL = safariURL
        self._isEditModeAvatar = isEditModeAvatar
        self.name = model.profileModel?.displayName ?? ""
        self.location = model.profileModel?.location ?? ""
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                AvatarPickerProfileViewWrapper(
                    avatarID: $model.avatarIdentifier,
                    forceRefreshAvatar: $model.forceRefreshAvatar,
                    model: $model.profileModel,
                    isLoading: $model.isProfileLoading,
                    safariURL: $safariURL,
                    isEditModeAvatar: $isEditModeAvatar
                )
                .padding(.top, AvatarPicker.Constants.profileViewTopSpacing)
                .padding(.bottom, AvatarPicker.Constants.vStackVerticalSpacing)
                .padding(.horizontal, AvatarPicker.Constants.horizontalPadding)

                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Display name")
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                // .background(Color.secondary)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        TextField(model.profileModel?.displayName ?? "", text: $name)
                            .focused($isNameFocused)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Spacer().frame(height: 24)
                        HStack {
                            Text("Location")
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                // .background(Color.secondary)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        TextField(model.profileModel?.location ?? "", text: $location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .avatarPickerBorder(colorScheme: colorScheme, borderWidth: 1)
                    // .background(Color.red)
                }
                .scrollDismissesKeyboard(.interactively)
                /* modifier(body: { scrollView in
                     if #available(iOS 16.0, *) {
                         scrollView
                             .scrollDismissesKeyboard(.interactively)
                     }
                 }) */
                .padding(.horizontal, 16)
                Spacer()
                CTAButtonView("Save")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            }
            .onAppear {
                isNameFocused = true
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        ProfileEditView(
            model: .init(email: .init("pinarolguc@gmail.com"), authToken: nil),
            safariURL: .constant(.init(url: URL(string: "https://wwww.gravatar.com"))),
            isEditModeAvatar: .constant(false)
        )
    } else {
        // Fallback on earlier versions
    }
}
