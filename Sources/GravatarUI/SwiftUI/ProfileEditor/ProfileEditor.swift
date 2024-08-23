import SwiftUI

public enum ProfileEditorEntryPoint {
    case avatarPicker
}

struct NavigationBarModel {
    let title: String
    let actionButtonEnabled: Bool
}

struct GravatarNavigationView<Content>: View where Content: View {
    @State var model: NavigationBarModel
    var content: () -> Content
    var onActionButtonPressed: (() -> Void)? = nil
    var onDoneButtonPressed: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            content()
                .navigationTitle(model.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            onActionButtonPressed?()
                        }) {
                            Image("gravatar", bundle: .module)
                                .tint(Color(UIColor.gravatarBlue))
                        }
                        .disabled(model.actionButtonEnabled)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            onDoneButtonPressed?()
                        }) {
                            Text("Done")
                                .tint(Color(UIColor.gravatarBlue))
                        }
                    }
                }
        }
    }
}

struct ProfileEditor: View {
    private enum Constants {
        static let title: String = "Gravatar" // defined here to avoid translations
    }
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
        switch entryPoint {
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
        }.gravatarNavigation(title: Constants.title, actionButtonDisabled: .constant(true), onDoneButtonPressed:  {
            isPresented = false
        })
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
    ProfileEditor(email: .init(""), entryPoint: .avatarPicker, isPresented: .constant(true))
}
