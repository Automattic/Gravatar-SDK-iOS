import SwiftUI

public enum QuickEditorScope: Sendable {
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
    @State var oauthError: OAuthError?
    @Binding var isPresented: Bool
    let email: Email
    let token: String?
    var customImageEditor: ImageEditorBlock<ImageEditor>?
    var contentLayoutProvider: AvatarPickerContentLayoutProviding

    init(
        email: Email,
        scope: QuickEditorScope,
        token: String? = nil,
        isPresented: Binding<Bool>,
        customImageEditor: ImageEditorBlock<ImageEditor>? = nil,
        contentLayoutProvider: AvatarPickerContentLayoutProviding = AvatarPickerContentLayout.vertical
    ) {
        self.email = email
        self.scope = scope
        self._isPresented = isPresented
        self.customImageEditor = customImageEditor
        self.contentLayoutProvider = contentLayoutProvider
        self.token = token
    }

    var body: some View {
        NavigationView {
            if let token {
                editorView(with: token)
            } else if hasSession, let token = oauthSession.sessionToken(with: email) {
                editorView(with: token)
            } else {
                noticeView()
                    .accumulateIntrinsicHeight()
            }
        }
    }

    @MainActor
    func editorView(with token: String) -> some View {
        switch scope {
        case .avatarPicker:
            AvatarPickerView(
                model: .init(email: email, authToken: token),
                isPresented: $isPresented,
                contentLayoutProvider: contentLayoutProvider,
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
                EmailText(email: email)
                ContentLoadingErrorView(
                    title: Constants.ErrorView.title(for: oauthError),
                    subtext: Constants.ErrorView.subtext(for: oauthError),
                    image: nil,
                    actionButton: {
                        Button {
                            performAuthentication()
                        } label: {
                            CTAButtonView(Constants.ErrorView.buttonTitle(for: oauthError))
                        }
                    },
                    innerPadding: .init(
                        top: .DS.Padding.double,
                        leading: .DS.Padding.double,
                        bottom: .DS.Padding.double,
                        trailing: .DS.Padding.double
                    )
                )
                .padding(.horizontal, .DS.Padding.double)
                Spacer()
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
            oauthError = nil
            if !oauthSession.hasSession(with: email) {
                do {
                    _ = try await oauthSession.retrieveAccessToken(with: email)
                } catch let error as OAuthError {
                    oauthError = error
                } catch {
                    // No op.
                }
            }
            hasSession = oauthSession.hasSession(with: email)
            isAuthenticating = false
        }
    }
}

extension QuickEditorConstants {
    enum ErrorView {
        static func title(for oauthError: OAuthError?) -> String {
            switch oauthError {
            case .loggedInWithWrongEmail:
                Localized.WrongEmailError.title
            default:
                Localized.LogInError.title
            }
        }

        static func subtext(for oauthError: OAuthError?) -> String {
            switch oauthError {
            case .loggedInWithWrongEmail(let email):
                String(format: Localized.WrongEmailError.subtext, email)
            default:
                Localized.LogInError.subtext
            }
        }

        static func buttonTitle(for oauthError: OAuthError?) -> String {
            Localized.LogInError.buttonTitle
        }
    }

    enum Localized {
        enum WrongEmailError {
            static let title = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.Retry.title",
                value: "Ooops",
                comment: "Title of a message advising the user that something went wrong while loading their avatars"
            )
            static let subtext = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.WrongEmailError.subtext",
                value: "It looks like you used the wrong email to log in. Please try again using %@ this time. Thanks!",
                comment: "A message describing the error and advising the user to login again to resolve the issue"
            )
        }

        enum LogInError {
            static let title = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.LogInError.title",
                value: "Login required",
                comment: "Title of a message advising the user that something went wrong while trying to log in."
            )

            static let buttonTitle = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.SessionExpired.LogInError.buttonTitle",
                value: "Log in",
                comment: "Title of a button that will begin the process of authenticating the user, appearing beneath a message stating that a previous log in attept has failed."
            )

            static let subtext = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.SessionExpired.LogInError.subtext",
                value: "To modify your Gravatar profile, you need to log in first.",
                comment: "A message describing the error and advising the user to login again to resolve the issue"
            )
        }
    }
}

#Preview {
    QuickEditor<NoCustomEditor>(
        email: .init(""),
        scope: .avatarPicker,
        isPresented: .constant(true),
        contentLayoutProvider: AvatarPickerContentLayoutWithPresentation.vertical(presentationStyle: .large)
    )
}
