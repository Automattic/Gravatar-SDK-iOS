import SwiftUI

struct AltTextEditorView: View {
    let avatar: AvatarImageModel?
    let email: Email?

    var shouldShowCharCount: Bool {
        altText.count > 0
    }

    @Environment(\.colorScheme) var colorScheme

    @State var altText: String = ""
    @State var charCount: Int = 0
    @State var safariURL: URL? = nil

    @FocusState var focused: Bool

    let onSave: (AvatarImageModel) -> Void
    let onCancel: () -> Void

    var body: some View {
        // Scroll view helps detaching the height of the child view from the height of the parent view.
        // This avoids a UI problem while scrolling down the sheet whith the keyboard being present.
        // GeometryReader also has the same effect. For now we want the content to scroll when the content grows.
        ScrollView {
            VStack {
                if let email {
                    EmailText(email: email)
                }
                VStack(alignment: .leading) {
                    HStack {
                        titleText
                        Spacer()
                        altTextHelpButton
                    }
                    ZStack(alignment: .bottomTrailing) {
                        HStack(alignment: .top) {
                            imageView
                            altTextField
                        }
                        if shouldShowCharCount {
                            characterCountText
                        }
                    }
                    Spacer()
                    actionButton
                }
                .padding()
                .avatarPickerBorder(colorScheme: .light)
            }
            .padding(.bottom)
            .padding(.horizontal)
        }
        .gravatarNavigation(
            doneButtonTitle: Localized.cancelButtonTitle,
            actionButtonDisabled: false,
            shouldEmitInnerHeight: false,
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
            TextEditor(text: $altText)
                .multilineTextAlignment(.leading)
                .frame(height: 100)
                .font(.footnote)
                .focused($focused)
                .onAppear { focused = true }
                .onChange(of: altText) { _ in
                    // Crops text to fit char limit.
                    altText = String(altText.prefix(Constants.characterLimit))
                }
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
        Button {
            if let avatar {
                onSave(avatar.updating { $0.altText = altText })
            }
        } label: {
            CTAButtonView(Localized.saveButtonTitle)
        }.padding(.top)
    }

    var characterCountText: some View {
        Text("\(altText.count)")
            .font(.callout)
            .foregroundColor(altText.count >= Constants.characterLimit ? .red : .secondary)
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

#Preview {
    struct AltTextPreview: View {
        @State var text = ""
        let avatar = AvatarImageModel.preview_init(
            id: "1",
            source: .remote(url: "https://gravatar.com/userimage/110207384/aa5f129a2ec75162cee9a1f0c472356a.jpeg?size=256")
        )

        var body: some View {
            AltTextEditorView(
                avatar: avatar,
                email: .init("some@email.com")
            ) { _ in } onCancel: {}
        }
    }

    return AltTextPreview()
}
