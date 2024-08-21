import SwiftUI

public enum ProfileEditorEntryPoint {
    case avatarPicker
}

struct ProfileEditor: View {
    @Environment(\.oauthSession) private var oauthSession
    @State var isSession: Bool = false
    @State var entryPoint: ProfileEditorEntryPoint

    let email: Email

    init(email: Email, entryPoint: ProfileEditorEntryPoint) {
        self.email = email
        self.entryPoint = entryPoint
    }

    var body: some View {
        VStack {
            if isSession, let token = oauthSession.sessionToken(with: email) {
                switch entryPoint {
                case .avatarPicker:
                    AvatarPickerView(model: .init(email: email, authToken: token))
                }
                Button("Log out (for testing only)") {
                    oauthSession.deleteSession(with: email)
                    isSession = oauthSession.isSession(with: email)
                }
            } else {
                Button("Authenticate (to be replaced)") {
                    Task {
                        _ = try? await oauthSession.authenticate(with: email)
                        isSession = oauthSession.isSession(with: email)
                    }
                }
            }
        }.task {
            isSession = oauthSession.isSession(with: email)
            if !isSession {
                Task {
                    _ = try? await oauthSession.authenticate(with: email)
                    isSession = oauthSession.isSession(with: email)
                }
            }
        }
    }
}

#Preview {
    ProfileEditor(email: .init(""), entryPoint: .avatarPicker)
}
