import SwiftUI

public enum ProfileEditorEntryPoint {
    case avatarPicker
}

struct ProfileEditor: View {
    @Environment(\.oauthSession) private var oauthSession
    @State var hasSession: Bool = false
    @State var entryPoint: ProfileEditorEntryPoint
    @State var isAuthenticating: Bool = true
    @Binding var isPresented: Bool

    let email: Email

    init(email: Email, entryPoint: ProfileEditorEntryPoint, isPresented: Binding<Bool>) {
        self.email = email
        self.entryPoint = entryPoint
        self._isPresented = isPresented
    }

    var body: some View {
        VStack {
            if hasSession, let token = oauthSession.sessionToken(with: email) {
                switch entryPoint {
                case .avatarPicker:
                    AvatarPickerView(model: .init(email: email, authToken: token), isPresented: $isPresented)
                }
            } else {
                if !isAuthenticating {
                    Button("Authenticate (Future error view)") {
                        Task {
                            performAuthentication()
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }.task {
            performAuthentication()
        }
    }

    @MainActor
    func performAuthentication() {
        Task {
            isAuthenticating = true
            if !oauthSession.hasSession(with: email) {
                _ = try? await oauthSession.retrieveAccessToken(with: email)
            }
            hasSession = oauthSession.hasSession(with: email)
            isAuthenticating = false
        }
    }
}

#Preview {
    ProfileEditor(email: .init(""), entryPoint: .avatarPicker, isPresented: .constant(true))
}
