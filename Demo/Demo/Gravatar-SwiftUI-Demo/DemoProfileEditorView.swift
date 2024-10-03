import SwiftUI
import GravatarUI

struct DemoProfileEditorView: View {

    @AppStorage("pickerEmail") private var email: String = ""
    @AppStorage("pickerContentLayoutOptions") private var contentLayoutOptions: QELayoutOptions = .verticalLarge
    // You can make this `true` by default to easily test the picker
    @State private var isPresentingPicker: Bool = false
    @State private var hasSession: Bool = false
    @State private var selectedScheme: UIUserInterfaceStyle = .unspecified
    @Environment(\.oauthSession) var oauthSession

    @State var profileModel: ProfileModel? = nil
    @State var avatarID: AvatarIdentifier? = nil {
        didSet {
            avatarRefreshTrigger.trigger()
        }
    }
    @State var avatarRefreshTrigger: RefreshTrigger = .init()

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                Divider()

                ProfileSummary(profileModel: $profileModel, avatarID: $avatarID, trigger: $avatarRefreshTrigger).frame(height: 160)
                QEContentLayoutPickerRow(contentLayoutOptions: $contentLayoutOptions)
                Divider()

                QEColorSchemePickerRow(selectedScheme: $selectedScheme)
            }
            .padding(.horizontal)
            Button("Open Profile Editor with OAuth flow") {
                isPresentingPicker.toggle()
            }
            .gravatarQuickEditorSheet(
                isPresented: $isPresentingPicker,
                email: email,
                scope: .avatarPicker(.init(contentLayout: contentLayoutOptions.contentLayout)),
                avatarUpdatedHandler: {
                    avatarRefreshTrigger.trigger()
                },
                onDismiss: {
                    updateHasSession(with: email)
                }
            )
            if hasSession {
                Button("Log out") {
                    oauthSession.deleteSession(with: .init(email))
                    updateHasSession(with: email)
                }
            }

            Spacer()
        }
        .onAppear() {
            updateHasSession(with: email)
            requestProfile()
        }
        .onChange(of: email) { _, newValue in
            updateHasSession(with: newValue)
            requestProfile()
        }
        .preferredColorScheme(ColorScheme(selectedScheme))
    }

    func requestProfile() {
        Task {
            let service = ProfileService()
            let profile = try await service.fetch(with: .email(email))
            print("Profile found")
            self.profileModel = profile
            self.avatarID = profile.avatarIdentifier
        }
    }

    func updateHasSession(with email: String) {
        hasSession = oauthSession.hasSession(with: .init(email))
    }
}

#Preview {
    DemoProfileEditorView()
}

struct ProfileSummary: UIViewRepresentable {
    @Binding var profileModel: ProfileModel?
    @Binding var avatarID: AvatarIdentifier?
    @Binding var trigger: RefreshTrigger

    func makeUIView(context: Context) -> GravatarUI.ProfileSummaryView {
        let pageViewController = ProfileSummaryView()
        return pageViewController
    }
    
    func updateUIView(_ uiView: GravatarUI.ProfileSummaryView, context: Context) {
        trigger.onTrigger = {
            uiView.loadAvatar(with: avatarID, options: [.forceRefresh])
        }

        uiView.update(with: profileModel)
    }
}

class RefreshTrigger: ObservableObject {
    var onTrigger: (() -> Void)?

    func trigger() {
        onTrigger?()
    }
}
