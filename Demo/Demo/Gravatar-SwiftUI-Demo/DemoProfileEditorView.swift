import SwiftUI
import GravatarUI

struct DemoProfileEditorView: View {

    @AppStorage("pickerEmail") private var email: String = ""

    // You can make this `true` by default to easily test the picker
    @State private var isPresentingPicker: Bool = false
    @State private var hasSession: Bool = false
    @Environment(\.oauthSession) var oauthSession

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)

                Divider()

            }
            .padding(.horizontal)
            Button("Open Profile Editor with OAuth flow") {
                isPresentingPicker.toggle()
            }
            .gravatarQuickEditorSheet(
                isPresented: $isPresentingPicker,
                email: email,
                scope: .avatarPicker,
                contentLayout: .horizontal(),
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
        }.onAppear() {
            updateHasSession(with: email)
        }
        .onChange(of: email) { _, newValue in
            updateHasSession(with: newValue)
        }
    }

    func updateHasSession(with email: String) {
        hasSession = oauthSession.hasSession(with: .init(email))
    }
}

#Preview {
    DemoAvatarPickerView()
}
