import Gravatar
import SwiftUI

@available(iOS, deprecated: 16.0, renamed: "QuickEditorScopeOption", message: "This will become internal in a next major release.")
public enum QuickEditorScopeType: Sendable {
    case avatarPicker
}

@available(*, deprecated, renamed: "QuickEditorScopeOption")
public enum QuickEditorScope: Sendable {
    case avatarPicker(AvatarPickerConfiguration)

    var scopeType: QuickEditorScopeType {
        switch self {
        case .avatarPicker:
            .avatarPicker
        }
    }
}

/// Represents the type of update that triggered a callback in the Quick Editor.
public struct QuickEditorUpdateType: Sendable, Equatable {
    private enum QEUpdateType {
        case avatarUpdate
        case aboutInfoUpdate
    }

    private let rawValue: QEUpdateType

    /// Indicates that the update was triggered by a change to the user's avatar.
    public static let avatarUpdate = Self(rawValue: .avatarUpdate)
    /// Indicates that the update was triggered by a change to the user's about section information.
    public static let aboutInfoUpdate = Self(rawValue: .aboutInfoUpdate)
}

struct QuickEditor<ImageEditor: ImageEditorView>: View {
    enum MultipleScopeMode {
        case avatarPicker
        case aboutEditor
    }

    fileprivate typealias Constants = QuickEditorConstants

    @Environment(\.oauthSession) private var oauthSession
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage("QuickEditor.startOAuthOnAppear") private var startOAuthOnAppear: Bool = false
    @State private var fetchedToken: String?
    @State private var isAuthenticating: Bool = false
    @State private var oauthError: OAuthError?
    @State private var safariURL: IdentifiableURL?
    /// If the QE is open with the scope switch option, this property will track which scope is currently being presented.
    /// It's nil when a single scope option was selected.
    @State private var multipleEditorMode: MultipleScopeMode? = nil

    @Binding private var isPresented: Bool
    // Declare "@StateObject"s as private to prevent setting them from a
    // memberwise initializer, which can conflict with the storage
    // management that SwiftUI provides.
    // https://developer.apple.com/documentation/swiftui/stateobject
    @StateObject private var model: AvatarPickerViewModel

    private let externalToken: String?
    private var token: String? { externalToken ?? fetchedToken }
    private let scopeOption: QuickEditorScopeOption
    private let email: Email
    private let customImageEditor: ImageEditorBlock<ImageEditor>?
    private let updateHandler: ((QuickEditorUpdateType) -> Void)?

    init(
        email: Email,
        scopeOption: QuickEditorScopeOption,
        token: String? = nil,
        isPresented: Binding<Bool>,
        customImageEditor: ImageEditorBlock<ImageEditor>? = nil,
        updateHandler: ((QuickEditorUpdateType) -> Void)? = nil
    ) {
        self.email = email
        self.scopeOption = scopeOption
        self._isPresented = isPresented
        self.customImageEditor = customImageEditor
        self.externalToken = token
        self.updateHandler = updateHandler
        self._model = StateObject(wrappedValue: AvatarPickerViewModel(email: email, authToken: token))
        if scopeOption.isAvatarPickerAndAboutInfoEditor {
            _multipleEditorMode = State(initialValue: .avatarPicker)
        }
    }

    let authorizationFinishedNotification = NotificationCenter.default.publisher(for: .authorizationFinished)
    let authorizationErrorNotification = NotificationCenter.default.publisher(for: .authorizationError)

    var body: some View {
        NavigationView {
            VStack {
                if token != nil {
                    editorView()
                } else {
                    noticeView()
                }
            }
            .gravatarNavigation(
                actionButtonDisabled: model.profileModel?.profileURL == nil,
                onDoneButtonPressed: {
                    isPresented = false
                },
                preferenceKey: InnerHeightPreferenceKey.self
            )
        }
        .presentSafariView(identifiableURL: $safariURL, colorScheme: colorScheme)
        .onAppear {
            fetchedToken = oauthSession.sessionToken(with: email)?.token
        }
        .onReceive(authorizationFinishedNotification) { _ in
            onAuthenticationFinished()
        }.onReceive(authorizationErrorNotification) { notification in
            guard let error = notification.object as? OAuthError else { return }
            oauthError = error
            onAuthenticationFinished()
        }
        .onChange(of: token) { newValue in
            if let newValue {
                model.update(authToken: newValue)
            }
        }
    }

    func avatarPickerView(config: AvatarPickerConfiguration) -> some View {
        AvatarPickerView(
            model: model,
            isPresented: $isPresented,
            contentLayoutProvider: config.contentLayout,
            customImageEditor: customImageEditor,
            tokenErrorHandler: externalToken != nil ? nil : {
                oauthSession.markSessionAsExpired(with: email)
                performAuthentication()
            },
            avatarUpdatedHandler: {
                updateHandler?(.avatarUpdate)
            }
        )
    }

    @ViewBuilder
    func aboutEditorView(fields: AboutInfoField) -> some View {
        AboutEditorView(
            model: model,
            fields: fields,
            aboutUpdateHandler: {
                updateHandler?(.aboutInfoUpdate)
            }
        )
    }

    @MainActor
    @ViewBuilder
    func editorView() -> some View {
        profileCardHeaderView()
        switch scopeOption.scope {
        case .avatarPicker(let config):
            avatarPickerView(config: config)
        case .aboutInfoEditor(let config):
            aboutEditorView(fields: config.fields)
        case .avatarPickerAndAboutInfoEditor(let config):
            switch multipleEditorMode {
            case .avatarPicker:
                avatarPickerView(config: .init(contentLayout: config.contentLayout))
            case .aboutEditor:
                aboutEditorView(fields: config.fields)
            case nil:
                EmptyView()
            }
        }
    }

    private func profileView() -> some View {
        AvatarPickerProfileViewWrapper(
            avatarID: $model.avatarIdentifier,
            forceRefreshAvatar: $model.forceRefreshAvatar,
            model: $model.profileModel,
            isLoading: $model.isProfileLoading,
            safariURL: $safariURL,
            buttonsMode: .constant(avatarProfileViewButtonMode),
            buttonTapHandler: profileButtonHandler
        )
        .padding(.top, AvatarPicker.Constants.profileViewTopSpacing / 2)
        .padding(.bottom, AvatarPicker.Constants.vStackVerticalSpacing)
        .padding(.horizontal, AvatarPicker.Constants.horizontalPadding)
    }

    func profileButtonHandler(_ mode: AvatarPickerProfileViewWrapper.ButtonsMode) {
        withAnimation {
            switch mode {
            case .avatar:
                multipleEditorMode = .avatarPicker
            case .aboutInfo:
                multipleEditorMode = .aboutEditor
            }
        }
    }

    var avatarProfileViewButtonMode: AvatarPickerProfileViewWrapper.ButtonsMode? {
        // We show the opposite button on the card, so the button mode corresponds to the opposite current mode shown
        switch multipleEditorMode {
        case .avatarPicker:
            .aboutInfo
        case .aboutEditor:
            .avatar
        case .none:
            nil
        }
    }

    @ViewBuilder
    func profileCardHeaderView() -> some View {
        EmailText(email: model.email)
            .accumulateIntrinsicHeight()
        profileView()
            .accumulateIntrinsicHeight()
    }

    func noticeView() -> some View {
        VStack(spacing: 0) {
            if !isAuthenticating {
                QuickEditorNoticeView(
                    email: email,
                    token: Binding(
                        get: { token },
                        set: { fetchedToken = $0 }
                    ),
                    oauthError: $oauthError,
                    model: model,
                    safariURL: $safariURL,
                    proceedAction: {
                        startOAuthOnAppear = true
                        performAuthentication()
                    }
                )
                .padding(.horizontal, AvatarPicker.Constants.horizontalPadding)
                .accumulateIntrinsicHeight()

                // Do not use `.accumulateIntrinsicHeight()` on `Spacer()`
                // Spacer's height will auto-increase and fill the gap that is
                // left from the default initial height of the bottom sheet,
                // causing the bottom sheet to stuck in that height.
                Spacer(minLength: 0)
            } else {
                ProgressView()
                    .accumulateIntrinsicHeight()
            }
        }
        .task(id: email) {
            await model.fetchProfile()
        }
        .task {
            if startOAuthOnAppear {
                performAuthentication()
            }
        }
    }

    @MainActor
    func performAuthentication() {
        Task {
            isAuthenticating = true
            if !oauthSession.hasValidSession(with: email) {
                do {
                    try await oauthSession.retrieveAccessToken(with: email)
                } catch OAuthError.oauthResponseError(_, let code) where code == .canceledLogin {
                    // ignore the error if the user has cancelled the operation.
                } catch let error as OAuthError {
                    oauthError = error
                } catch {
                    oauthError = nil
                }
            }
            onAuthenticationFinished()
        }
    }

    func onAuthenticationFinished() {
        if let fetchedToken = oauthSession.sessionToken(with: email)?.token {
            self.fetchedToken = fetchedToken
            oauthError = nil
        }
        isAuthenticating = false
    }
}

enum QuickEditorConstants {
    enum ErrorView {
        static func title(for oauthError: OAuthError?) -> String? {
            switch oauthError {
            case .loggedInWithWrongEmail:
                Localized.WrongEmailError.title
            default:
                nil
            }
        }

        static func subtext(for oauthError: OAuthError?) -> String {
            switch oauthError {
            case .loggedInWithWrongEmail(let email):
                String(format: Localized.WrongEmailError.subtext, email)
            default:
                Localized.MissingToken.subtext
            }
        }

        static func buttonTitle(for oauthError: OAuthError?) -> String {
            Localized.MissingToken.buttonTitle
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

        enum MissingToken {
            static let headline = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.MissingToken.headline",
                value: "Edit your Profile",
                comment: "Headline of an intro screen for editing a user's profile."
            )

            static let subheadline = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.MissingToken.subheadline",
                value: "Enhance your %@ profile with Gravatar.",
                comment: "Subheadline of an intro screen for editing a user's profile. %@ is the name of a mobile app that uses Gravatar services."
            )

            static let buttonTitle = SDKLocalizedString(
                "AvatarPicker.Continue.title",
                value: "Continue",
                comment: "Title of a button that will proceed with the action."
            )

            static let subtext = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.MissingToken.subtext",
                value: "Manage your profile for the web in one place.",
                comment: "A message that informs the user about Gravatar."
            )
        }
    }
}

#Preview {
    QuickEditor<NoCustomEditor>(
        email: .init(""),
        scopeOption: .aboutEditor(.init()),
        isPresented: .constant(true)
    )
}
