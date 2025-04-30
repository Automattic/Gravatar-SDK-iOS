import SwiftUI

@MainActor
extension View {
    public func shape(_ shape: some Shape, borderColor: Color = .clear, borderWidth: CGFloat = 0) -> some View {
        self
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }

    func avatarPickerBorder(colorScheme: ColorScheme, borderWidth: CGFloat = 1) -> some View {
        self
            .shape(
                RoundedRectangle(cornerRadius: 8),
                borderColor: Color(UIColor.label).opacity(colorScheme == .dark ? 0.16 : 0.08),
                borderWidth: borderWidth
            )
            .padding(.vertical, borderWidth) // to prevent borders from getting clipped
    }

    /// A modifier to display the QuickEditor sheet. The QuickEditor allows updating the Gravatar profile information and avatar.
    /// - Parameters:
    ///   - isPresented: A Binding boolean to manage showing/hiding the sheet.
    ///   - email: Email for the Gravatar account.
    ///   - authToken: (Optional) Gravatar OAuth token. If not passed, Gravatar OAuth flow will start to gather the token internally.
    ///   Pass this only if your app already has a Gravatar OAuth token.
    ///   - scope: Scope for the QuickEditor.
    ///   - customImageEditor: (Optional) A custom image editor to show the user right after an image is picked for
    ///   cropping and other sorts of image editing operations.
    ///   - avatarUpdatedHandler: (Optional) A callback to execute when a different avatar is selected.
    ///   - onDismiss: (Optional) A callback to execute when the sheet is dismissed.
    /// - Returns: A modifier to display the QuickEditor sheet.
    @available(iOS, deprecated: 16.0, message: "Use the new method that takes in `QuickEditorScopeOption`.")
    @available(*, deprecated, renamed: "gravatarQuickEditorSheet(isPresented:email:authToken:scopeOption:customImageEditor:updatedHandler:onDismiss:)")
    public func gravatarQuickEditorSheet(
        isPresented: Binding<Bool>,
        email: String,
        authToken: String? = nil,
        scope: QuickEditorScopeType,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?,
        avatarUpdatedHandler: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        let editor = QuickEditor(
            email: .init(email),
            scope: QuickEditorScopeOption.avatarPicker(),
            token: authToken,
            isPresented: isPresented,
            customImageEditor: customImageEditor,
            updateHandler: { _ in
                avatarUpdatedHandler?()
            }
        )
        return modifier(ModalPresentationModifier(isPresented: isPresented, onDismiss: onDismiss, modalView: editor))
    }

    /// A modifier to display the QuickEditor sheet. The QuickEditor can be used to modify the information and avatar images of your Gravatar profile.
    /// - Parameters:
    ///   - isPresented: A Binding boolean to manage showing/hiding the sheet.
    ///   - email: Email for the Gravatar account.
    ///   - authToken: (Optional) Gravatar OAuth token. If not passed, Gravatar OAuth flow will start to gather the token internally.
    ///   Pass this only if your app already has a Gravatar OAuth token.
    ///   - scope: Scope for the QuickEditor. See: ``QuickEditorScope``.
    ///   - customImageEditor: (Optional) A custom image editor to show the user right after an image is picked for
    ///   cropping and other sorts of image editing operations.
    ///   - avatarUpdatedHandler: (Optional) A callback to execute when a different avatar is selected.
    ///   - onDismiss: (Optional) A callback to execute when the sheet is dismissed.
    /// - Returns: A modifier to display the QuickEditor sheet.
    @available(iOS 16.0, *)
    @available(*, deprecated, renamed: "gravatarQuickEditorSheet(isPresented:email:authToken:scopeOption:customImageEditor:avatarUpdatedHandler:onDismiss:)")
    public func gravatarQuickEditorSheet(
        isPresented: Binding<Bool>,
        email: String,
        authToken: String? = nil,
        scope: QuickEditorScope,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?,
        avatarUpdatedHandler: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        switch scope {
        case .avatarPicker(let config):
            let editor = QuickEditor(
                email: .init(email),
                scope: QuickEditorScopeOption.avatarPicker(.init(contentLayout: config.contentLayout)),
                token: authToken,
                isPresented: isPresented,
                customImageEditor: customImageEditor,
                updateHandler: { _ in
                    avatarUpdatedHandler?()
                }
            )
            return modifier(QuickEditorModalPresentationModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                modalView: editor,
                contentLayout: config.contentLayout
            ))
        }
    }

    /// A modifier to display the QuickEditor sheet. The QuickEditor can be used to modify the information and avatar images of your Gravatar profile.
    /// - Parameters:
    ///   - isPresented: A `Binding<Bool>` to control the presentation of the sheet.
    ///   - email: The email address associated with the Gravatar account.
    ///   - authToken: *(Optional)* A Gravatar OAuth token. If not provided, the QuickEditor will initiate
    ///   the Gravatar OAuth flow to obtain a token. Provide this only if your app already has a token.
    ///   - scopeOption: The scope option for the QuickEditor. See: ``QuickEditorScopeOption``.
    ///   - customImageEditor: *(Optional)* A custom image editor provider to use after the user picks an image in the Avatar Picker.
    ///   - updateHandler: *(Optional)* A closure called when the user makes a change on their profile.
    ///   - onDismiss: *(Optional)* A closure called when the sheet is dismissed.
    /// - Returns: A view modifier that presents the QuickEditor sheet.
    @ViewBuilder
    @available(iOS 16, *)
    public func gravatarQuickEditorSheet(
        isPresented: Binding<Bool>,
        email: String,
        authToken: String? = nil,
        scopeOption scope: QuickEditorScopeOption,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?,
        updateHandler: ((QuickEditorUpdateType) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        let editor = QuickEditor(
            email: .init(email),
            scope: scope,
            token: authToken,
            isPresented: isPresented,
            customImageEditor: customImageEditor,
            updateHandler: updateHandler
        )
        let contentLayout = switch scope.scope {
        case .avatarPicker: scope.avatarPickerConfig.contentLayout
        case .aboutInfoEditor: AvatarPickerContentLayout.vertical(
                presentationStyle: scope.aboutEditorConfig.presentationStyle
            )
        }
        modifier(QuickEditorModalPresentationModifier(
            isPresented: isPresented,
            onDismiss: onDismiss,
            modalView: editor,
            contentLayout: contentLayout
        ))
    }

    /// A modifier to display the QuickEditor sheet. The QuickEditor can be used to modify the information and avatar images of your Gravatar profile.
    /// - Parameters:
    ///   - isPresented: A `Binding<Bool>` to control the presentation of the sheet.
    ///   - email: The email address associated with the Gravatar account.
    ///   - authToken: *(Optional)* A Gravatar OAuth token. If not provided, the QuickEditor will initiate
    ///   the Gravatar OAuth flow to obtain a token. Provide this only if your app already has a token.
    ///   - scopeOption: The scope option for the QuickEditor. See: ``QuickEditorScopeOption``.
    ///   - customImageEditor: *(Optional)* A custom image editor provider to use after the user picks an image in the Avatar Picker.
    ///   - updateHandler: *(Optional)* A closure called when the user makes a change on their profile.
    ///   - onDismiss: *(Optional)* A closure called when the sheet is dismissed.
    /// - Returns: A view modifier that presents the QuickEditor sheet.
    @ViewBuilder
    @available(iOS, deprecated: 16.0, message: "Use the new method that takes in `QuickEditorScopeOption`.")
    public func gravatarQuickEditorSheet(
        isPresented: Binding<Bool>,
        email: String,
        authToken: String? = nil,
        scopeOption scope: QuickEditorScopeOptionOld,
        customImageEditor: ImageEditorBlock<some ImageEditorView>? = nil as NoCustomEditorBlock?,
        updateHandler: ((QuickEditorUpdateType) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        let editor = QuickEditor(
            email: .init(email),
            scope: scope.map(),
            token: authToken,
            isPresented: isPresented,
            customImageEditor: customImageEditor,
            updateHandler: updateHandler
        )

        modifier(
            ModalPresentationModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                modalView: editor
            )
        )
    }

    func altTextSheet(
        model: Binding<AvatarImageModel?>,
        email: Email,
        toastManager: ToastManager,
        colorScheme: ColorScheme,
        onSave: @escaping (AvatarImageModel) async -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        func altTextEditor(with model: AvatarImageModel) -> some View {
            NavigationView {
                AltTextEditorView(avatar: model, email: email, toastManager: toastManager, onSave: onSave, onCancel: onCancel)
            }
            .colorScheme(colorScheme)
        }

        if #available(iOS 16.0, *) {
            return self.sheet(item: model, onDismiss: onCancel) { selectedModel in
                altTextEditor(with: selectedModel).presentationDetents([.height(AltTextEditorView.Constants.sheetHeight)])
            }
        } else {
            return modifier(
                ModalItemPresentationModifier(
                    item: model,
                    onDismiss: onCancel,
                    modalView: altTextEditor
                )
            )
        }
    }

    func presentationContentInteraction(shouldPrioritizeScrolling: Bool) -> some View {
        if #available(iOS 16.4, *) {
            let behavior: PresentationContentInteraction = shouldPrioritizeScrolling ? .scrolls : .automatic
            return self
                .presentationContentInteraction(behavior)
        } else {
            return self
        }
    }

    /// Applies detents for iOS 16+.
    func presentationDetentsIfAvailable(_ detents: [QEDetent]) -> some View {
        if #available(iOS 16.0, *) {
            return self.presentationDetents(detents.map())
        } else {
            return self
        }
    }

    /// Caution: `InnerHeightPreferenceKey` accumulates the values so DO NOT use this on  a View and one of its ancestors at the same time.
    @ViewBuilder
    func accumulateIntrinsicHeight<K>(key: K.Type = InnerHeightPreferenceKey.self) -> some View where K: PreferenceKey, K.Value == CGFloat {
        self.background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: key,
                    value: proxy.size.height
                )
            }
        }
    }

    @ViewBuilder
    public func imagePlaygroundSheetIfAvailable(
        isPresented: Binding<Bool>,
        sourceImage: Image? = nil,
        onCompletion: @escaping (URL) -> Void,
        onCancellation: (() -> Void)? = nil
    ) -> some View {
        if #available(iOS 18.2, *) {
            self.imagePlaygroundSheet(isPresented: isPresented, sourceImage: sourceImage, onCompletion: onCompletion, onCancellation: onCancellation)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    func presentSafariView(identifiableURL: Binding<IdentifiableURL?>, colorScheme: ColorScheme) -> some View {
        self.sheet(item: identifiableURL) { identifiableURL in
            SafariView(url: identifiableURL.url)
                .edgesIgnoringSafeArea(.all)
                .colorScheme(colorScheme)
        }
    }
}
