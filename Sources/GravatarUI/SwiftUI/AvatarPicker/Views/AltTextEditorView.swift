import SwiftUI

struct AltTextEditorView: View {
    let avatar: AvatarImageModel?
    let email: Email

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @State var altText: String = ""
    @State var charCount: Int = 0
    @State var safariURL: URL? = nil
    @State var isLoading: Bool = false
    @ObservedObject var toastManager: ToastManager

    @FocusState var focused: Bool

    let onSave: (AvatarImageModel) async -> Void
    let onCancel: () -> Void

    var counterPadding: CGFloat {
        switch dynamicTypeSize {
        case let size where size <= .large: 0
        case let size where size < .xxxLarge: -10
        case let size where size >= .xxxLarge: -18
        default: 0
        }
    }

    var normalSizeTextEditorLayout: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .top) {
                imageView
                altTextField
            }
            characterCountText.padding(.bottom, counterPadding)
        }.padding(.bottom, 12)
    }

    var accessibilitySizeTextEditorLayout: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .top) {
                imageView
                altTextField
            }
            characterCountText.padding(.top, -6).padding(.bottom, -4)
        }
    }

    var body: some View {
        // Scroll view helps detaching the height of the child view from the height of the parent view.
        // This avoids a UI problem while scrolling down the sheet with the keyboard being present.
        // GeometryReader also has the same effect. For now we want the content to scroll when the content grows.
        ScrollView {
            ZStack {
                VStack {
                    EmailText(email: email)
                    VStack(alignment: .leading) {
                        HStack {
                            titleText
                            Spacer()
                            altTextHelpButton
                        }
                        if dynamicTypeSize >= .accessibility1 {
                            accessibilitySizeTextEditorLayout
                        } else {
                            normalSizeTextEditorLayout
                        }

                        actionButton
                            .disabled(isLoading)
                    }
                    .padding()
                    .avatarPickerBorder(colorScheme: .light)
                }
                .padding(.bottom)
                .padding(.horizontal)
                errorToast
            }
        }
        .gravatarNavigation(
            doneButtonTitle: Localized.cancelButtonTitle,
            doneButtonDisabled: isLoading,
            actionButtonDisabled: false,
            onDoneButtonPressed: {
                onCancel()
            },
            preferenceKey: ConstantHeightPreferenceKey.self
        )
        .presentSafariView(url: $safariURL, colorScheme: colorScheme)
        .onAppear {
            altText = avatar?.altText ?? ""
        }
    }

    var altTextField: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: Binding(
                get: { altText.normalizedAltText },
                set: { newAltText in
                    if newAltText.contains("\n") {
                        focused = false
                    }
                    altText = newAltText.normalizedAltText
                }
            ))
            .multilineTextAlignment(.leading)
            .frame(height: dynamicTypeSize >= .accessibility1 ? 120 : Constants.minLength)
            .font(.footnote)
            .focused($focused)
            .submitLabel(.done)
            .onAppear { focused = true }
            if altText.count == 0 {
                Text(Localized.altTextPlaceholder)
                    .padding(8)
                    // Exactly possitions placeholder over TextEditor text.
                    .padding(.leading, -3)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }

    var titleText: some View {
        Text(Localized.pageTitle)
            .font(.title2)
            .fontWeight(.semibold)
    }

    var actionButton: some View {
        ZStack(alignment: .center) {
            Button {
                if let avatar {
                    isLoading = true
                    Task {
                        await onSave(avatar.updating { $0.altText = altText })
                        isLoading = false
                    }
                }
            } label: {
                CTAButtonView(Localized.saveButtonTitle)
            }
            .disabled(isLoading)
            if isLoading {
                ProgressView()
            }
        }
    }

    var characterCountText: some View {
        Text("\(Constants.characterLimit - altText.count)")
            .font(.footnote)
            .monospacedDigit()
            .foregroundColor(altText.count >= Constants.characterLimit ? .red : .secondary)
            .padding(.trailing, 4)
    }

    var altTextHelpButton: some View {
        Button(Localized.helpButtonTitle) {
            safariURL = URL(string: "https://support.gravatar.com/profiles/avatars/#add-alt-text-to-avatars")
        }.font(.footnote)
    }

    var imageView: some View {
        AvatarView(
            url: avatar?.url,
            placeholderView: { avatar?.localImage?.resizable() },
            loadingView: {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        ).scaledToFill()
            .frame(width: Constants.imageSize, height: Constants.imageSize)
            .background(Color(UIColor.secondarySystemBackground))
            .aspectRatio(1, contentMode: .fill)
            .shape(RoundedRectangle(cornerRadius: AvatarGridConstants.avatarCornerRadius))
    }

    var errorToast: some View {
        ToastContainerView(toastManager: toastManager)
            .padding(.horizontal)
    }
}

extension AltTextEditorView {
    fileprivate enum Localized {
        static let pageTitle = SDKLocalizedString(
            "AltText.Editor.title",
            value: "Alt Text",
            comment: "The title of Alt Text editor screen."
        )
        static let altTextPlaceholder = SDKLocalizedString(
            "AltText.Editor.placeholder",
            value: "Write alt text...",
            comment: "Placeholder text for Alt Text editor text field."
        )
        static let saveButtonTitle = SDKLocalizedString(
            "AltText.Editor.saveButtonTitle",
            value: "Save",
            comment: "Title for Save button."
        )
        static let cancelButtonTitle = SDKLocalizedString(
            "AltText.Editor.cancelButtonTitle",
            value: "Cancel",
            comment: "Title for Cancel button."
        )
        static let helpButtonTitle = SDKLocalizedString(
            "AltText.Editor.helpButtonTitle",
            value: "What is alt text?",
            comment: "Title for Help button which opens a view explaining what alt text is."
        )
    }
}

extension AltTextEditorView {
    enum Constants {
        static let sheetHeight: CGFloat = 330
        fileprivate static let imageSize: CGFloat = 96
        fileprivate static let minLength: CGFloat = 96
        fileprivate static let characterLimit: Int = 100
    }
}

extension String {
    fileprivate var normalizedAltText: String {
        String(self.prefix(AltTextEditorView.Constants.characterLimit))
            .replacingOccurrences(of: "\n", with: "")
    }
}

#Preview {
    struct AltTextPreview: View {
        @State var text = ""
        let avatar = AvatarImageModel.preview_init(
            id: "1",
            source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256")
        )
        @ObservedObject var toast = ToastManager()

        var body: some View {
            NavigationView {
                AltTextEditorView(
                    avatar: avatar,
                    email: .init("some@email.com"),
                    toastManager: toast
                ) { _ in
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                } onCancel: {
                    toast.showToast("Error", type: .error)
                }
            }
        }
    }

    return AltTextPreview()
}
