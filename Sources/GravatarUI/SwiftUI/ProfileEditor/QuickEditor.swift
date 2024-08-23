import SwiftUI

public enum QuickEditorScope {
    case avatarPicker
}

struct QuickEditor: View {
    private enum Constants {
        static let title: String = "Gravatar" // defined here to avoid translations
    }

    @Environment(\.oauthSession) private var oauthSession
    @State var hasSession: Bool = false
    @State var scope: QuickEditorScope
    @State var isAuthenticating: Bool = true
    @Binding var isPresented: Bool

    let email: Email

    init(email: Email, scope: QuickEditorScope, isPresented: Binding<Bool>) {
        self.email = email
        self.scope = scope
        self._isPresented = isPresented
    }

    var body: some View {
        NavigationView {
            if hasSession, let token = oauthSession.sessionToken(with: email) {
                editorView(with: token)
            } else {
                noticeView()
            }
        }
    }

    @MainActor
    func editorView(with token: String) -> some View {
        switch scope {
        case .avatarPicker:
            AvatarPickerView(model: .init(email: email, authToken: token), isPresented: $isPresented)
        }
    }

    @MainActor
    func noticeView() -> some View {
        VStack {
            if !isAuthenticating {
                Button("Authenticate (Future error view)") {
                    Task {
                        performAuthentication()
                    }
                }
            } else {
                ProgressView()
            }
        }.gravatarNavigation(
            title: Constants.title,
            actionButtonDisabled: true,
            onDoneButtonPressed: {
                isPresented = false
            }
        )
        .task {
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
    QuickEditor(email: .init(""), scope: .avatarPicker, isPresented: .constant(true))
}
