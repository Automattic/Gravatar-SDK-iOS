import SwiftUI

public enum QuickEditorScope {
    case avatarPicker
}

private enum QuickEditorConstants {
    static let title: String = "Gravatar" // defined here to avoid translations
}

struct QuickEditor<ImageEditor: ImageEditorView>: View {
    fileprivate typealias Constants = QuickEditorConstants

    @Environment(\.oauthSession) private var oauthSession
    @State var hasSession: Bool = false
    @State var scope: QuickEditorScope
    @State var isAuthenticating: Bool = true
    @Binding var isPresented: Bool
    let email: Email
    var customImageEditor: ImageEditorBlock<ImageEditor>?
    var contentLayoutProvider: AvatarPickerContentLayoutProviding

    init(email: Email, scope: QuickEditorScope, isPresented: Binding<Bool>, customImageEditor: ImageEditorBlock<ImageEditor>? = nil, contentLayoutProvider: AvatarPickerContentLayoutProviding = AvatarPickerContentLayout.vertical) {
        self.email = email
        self.scope = scope
        self._isPresented = isPresented
        self.customImageEditor = customImageEditor
        self.contentLayoutProvider = contentLayoutProvider
    }

    var body: some View {
        VStack {
            NavigationView {
                if hasSession, let token = oauthSession.sessionToken(with: email) {
                    editorView(with: token)
                } else {
                    noticeView()
                        .accumulateIntrinsicHeight()
                }
            }
        }
    }

    @MainActor
    func editorView(with token: String) -> some View {
        switch scope {
        case .avatarPicker:
            AvatarPickerView(
                model: .init(email: email, authToken: token),
                contentLayoutProvider: contentLayoutProvider, 
                isPresented: $isPresented,
                customImageEditor: customImageEditor,
                tokenErrorHandler: {
                    oauthSession.deleteSession(with: email)
                    performAuthentication()
                }
            )
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
    QuickEditor<NoCustomEditor>(email: .init(""), scope: .avatarPicker, isPresented: .constant(true), contentLayoutProvider: AvatarPickerContentLayoutWithPresentation.vertical(presentationStyle: .large))
}
