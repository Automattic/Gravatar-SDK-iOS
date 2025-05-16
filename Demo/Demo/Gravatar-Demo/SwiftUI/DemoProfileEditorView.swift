import SwiftUI
import GravatarUI

struct DemoProfileEditorView: View {

    @AppStorage("pickerEmail") private var email: String = ""
    @AppStorage("pickerToken") private var token: String = ""
    @AppStorage("pickerContentLayoutOptions") private var contentLayoutOptions: AvatarPickerLayoutOptions = .verticalLarge
    // You can make this `true` by default to easily test the picker
    @State private var isPresentingPicker: Bool = false
    @State private var hasSession: Bool = false
    @AppStorage("demoColorScheme") private var selectedScheme: UIUserInterfaceStyle = .unspecified
    @Environment(\.oauthSession) var oauthSession

    @State private var profileConfiguration: ProfileViewConfiguration = .summary()
    @State private var oneTimeAvatarForceRefresh: Bool = false
    @State private var isSecure: Bool = true
    @State var enableCustomImageCropper: Bool = false
    @State var prefersEphemeralWebBrowserSession: Bool = false
    @AppStorage("demoSelectedScope") private var scope: QEScope = .avatarPicker
    @State private var verticalPresentationStyle: VerticalContentPresentationStyle = .expandableMedium()
    @State private var isPresentingAboutFieldsSheet: Bool = false
    @AppStorage("demoSelectedAboutInfoFields") var selectedAboutInfoFields: AboutInfoField = .all
    @AppStorage("demoSelectedAvatar&AboutInitialPage") var initialPage: InitialPage = .avatarPicker

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .font(.callout)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    tokenField()
                        .font(.callout)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .disableAutocorrection(true)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {
                        isSecure.toggle()
                    }) {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                Spacer().frame(height: 8)
                ProfileViewRepresentable(
                    configuration: $profileConfiguration,
                    oneTimeAvatarForceRefresh: $oneTimeAvatarForceRefresh
                )
                Divider()
                Toggle("Prefers ephemeral browser session", isOn: $prefersEphemeralWebBrowserSession)
                Divider()
                QEColorSchemePickerRow(selectedScheme: $selectedScheme)
                Divider()
                QEScopesPickerRow(scope: $scope)
                Divider()
                scopeOptions()
            }
            .padding(.horizontal)
                Button("Open Profile Editor with OAuth flow") {
                    isPresentingPicker.toggle()
                }
                .modifier { view in
                    if #available(iOS 16, *) {
                        view
                            .gravatarQuickEditorSheet(
                                isPresented: $isPresentingPicker,
                                email: email,
                                authToken: !token.isEmpty ? token : nil,
                                scopeOption: finalScope,
                                customImageEditor: customImageEditor(),
                                updateHandler: { updateType in
                                    switch updateType {
                                    case is QuickEditorUpdate.Avatar:
                                        self.oneTimeAvatarForceRefresh = true
                                    case let update as QuickEditorUpdate.AboutInfo:
                                        self.setNewProfile(update.profile)
                                    default: break
                                    }
                                },
                                onDismiss: {
                                    updateHasSession(with: email)
                                }
                            ).environment(\.colorScheme, ColorScheme(selectedScheme) ?? .light)
                    } else {
                        view
                            .gravatarQuickEditorSheet(
                                isPresented: $isPresentingPicker,
                                email: email,
                                authToken: !token.isEmpty ? token : nil,
                                scopeOption: finalScopeiOS16,
                                customImageEditor: customImageEditor(),
                                updateHandler: { updateType in
                                    switch updateType {
                                    case is QuickEditorUpdate.Avatar:
                                        self.oneTimeAvatarForceRefresh = true
                                    case let update as QuickEditorUpdate.AboutInfo:
                                        self.setNewProfile(update.profile)
                                    default: break
                                    }
                                },
                                onDismiss: {
                                    updateHasSession(with: email)
                                }
                            ).environment(\.colorScheme, ColorScheme(selectedScheme) ?? .light)
                    }
                }
            if hasSession {
                Button("Log out") {
                    oauthSession.deleteSession(with: .init(email))
                    updateHasSession(with: email)
                }
            }

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear() {
            updateHasSession(with: email)
            requestProfile()
        }
        .onChange(of: email) { newValue in
            updateHasSession(with: newValue)
            requestProfile()
        }
        .onChange(of: prefersEphemeralWebBrowserSession) { newValue in
            Task {
                await oauthSession.setPrefersEphemeralWebBrowserSession(prefersEphemeralWebBrowserSession)
            }
        }
        .sheet(isPresented: $isPresentingAboutFieldsSheet) {
            if #available(iOS 16.0, *) {
                AboutInfoChecklistView(selectedFields: $selectedAboutInfoFields)
                    .presentationDetents([.medium, .large])
            } else {
                AboutInfoChecklistView(selectedFields: $selectedAboutInfoFields)
            }
        }
    }

    var finalScope: QuickEditorScopeOption {
        switch scope {
        case .avatarPicker:
            .avatarPicker(.init(contentLayout: contentLayoutOptions.contentLayout))
        case .aboutEditor:
            .aboutEditor(.init(
                presentationStyle: verticalPresentationStyle,
                fields: selectedAboutInfoFields)
            )
        case .avatarAndAboutEditor:
            .avatarPickerAndAboutInfoEditor(
                .init(
                    contentLayout: contentLayoutOptions.contentLayout,
                    fields: selectedAboutInfoFields,
                    initialPage: initialPage.map()
                )
            )
        }
    }

    var finalScopeiOS16: QuickEditorScopeOptionOld {
        switch scope {
        case .avatarPicker:
            .avatarPicker()
        case .aboutEditor:
            .aboutEditor()
        case .avatarAndAboutEditor:
            .avatarPicker()
        }
    }

    @ViewBuilder
    func scopeOptions() -> some View {
        switch scope {
        case .avatarPicker:
            if #available(iOS 16.0, *) {
                QEContentLayoutPickerRow(contentLayoutOptions: $contentLayoutOptions)
                Divider()
            }
            Toggle("Custom image cropper", isOn: $enableCustomImageCropper)
        case .aboutEditor:
            if #available(iOS 16.0, *) {
                QEVerticalStylePickerRow(verticalStyle: $verticalPresentationStyle)
            }
            aboutFieldsButton()
        case .avatarAndAboutEditor:
            if #available(iOS 16.0, *) {
                QEContentLayoutPickerRow(contentLayoutOptions: $contentLayoutOptions)
                Divider()
            }
            Toggle("Custom image cropper", isOn: $enableCustomImageCropper)
            aboutFieldsButton()
            initialPageOption()
        }
    }

    func aboutFieldsButton() -> some View {
        HStack(alignment: .center) {
            Spacer()
            Button("Select input fields") {
                isPresentingAboutFieldsSheet = true
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
    }

    func initialPageOption() -> some View {
        HStack {
            Text("Initial Page")
            Spacer()
            Picker("Initial Page", selection: $initialPage) {
                ForEach(InitialPage.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }

    func requestProfile() {
        Task {
            let service = ProfileService()
            let profile = try await service.fetch(with: .email(email))
            setNewProfile(profile)
        }
    }

    func setNewProfile(_ profile: Profile) {
        var newConfig = self.profileConfiguration
        newConfig.avatarIdentifier = profile.avatarIdentifier
        newConfig.model = profile
        newConfig.summaryModel = profile
        self.profileConfiguration = newConfig
    }

    func updateHasSession(with email: String) {
        hasSession = oauthSession.hasSession(with: .init(email))
    }
    
    @ViewBuilder
    func tokenField() -> some View {
        if isSecure {
            SecureField("Token", text: $token)
        } else {
            TextField("Token", text: $token)
        }
    }
    
    private func customImageEditor() -> ImageEditorBlock<TestImageCropper>? {
        if enableCustomImageCropper {
            let block = { image, editingDidFinish in
                TestImageCropper(inputImage: image, editingDidFinish: editingDidFinish)
            }
            return block
        }
        return nil as ImageEditorBlock<TestImageCropper>?
    }
}

#Preview {
    DemoProfileEditorView()
}
