import SwiftUI

struct AboutEditorView: View {
    private enum Constants {
        static let primaryFont: Font = .subheadline
        static let sectionHeaderFont: Font = .subheadline.weight(.semibold)
        static let footerFont: Font = .footnote
        static let horizontalPadding: CGFloat = .DS.Padding.double
        static let vStackVerticalSpacing: CGFloat = .DS.Padding.medium
    }

    @State private var isSaving: Bool = false
    @Binding var isPresented: Bool

    @FocusState private var isKeyboardPresented

    @ObservedObject var model: AvatarPickerViewModel
    let fields: AboutInfoField
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.verticalSizeClass) var vertcalSizeClass

    var tokenErrorHandler: (() -> Void)?
    var aboutUpdateHandler: ((Profile) -> Void)?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if model.isProfileLoading {
                    LoadingIndicatorView()
                        .accumulateIntrinsicHeight()
                    // Avoid calling `.accumulateIntrinsicHeight()` on `Spacer()`.
                    // It results in incorrect intrinsic size calculation because `Spacer()` height is flexible.
                    Spacer()
                } else if let error = model.profileResult?.error() {
                    errorView(with: error)
                        .accumulateIntrinsicHeight()
                    // Avoid calling .accumulateIntrinsicHeight() on Spacer().
                    // It results in incorrect intrinsic size calculation because `Spacer()` height is flexible.
                    Spacer()
                } else {
                    content()
                }
            }
            ToastContainerView(toastManager: model.toastManager)
                .padding(.horizontal, Constants.horizontalPadding * 2)
        }
        .focused($isKeyboardPresented)
        .onChange(of: isKeyboardPresented) { newValue in
            guard model.isKeyboardPresented != newValue else { return }
            model.isKeyboardPresented = newValue
        }
        .onChange(of: model.isKeyboardPresented) { newValue in
            guard isKeyboardPresented != newValue else { return }
            isKeyboardPresented = newValue
        }
    }

    @ViewBuilder
    private func content() -> some View {
        VStack(spacing: 0) {
            // Call .accumulateIntrinsicHeight() for the "contents" of
            // the ScrollView not the ScrollView itself.
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    personalInfoContent()
                    if fields.hasMultipleCategories(containing: .professionalFields) {
                        Spacer().frame(height: .DS.Padding.double)
                    }
                    professionalInfoContent()
                    if fields.hasMultipleCategories(containing: .extraFields) {
                        Spacer().frame(height: .DS.Padding.double)
                    }
                    extraFieldsContent()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, .DS.Padding.double)
                .padding(.vertical, .DS.Padding.double)
                .accumulateIntrinsicHeight()
            }
        }
        .avatarPickerBorder(colorScheme: colorScheme, borderWidth: 1)
        .padding(.horizontal, .DS.Padding.double)

        // It's ok to call .accumulateIntrinsicHeight() on a Spacer() as soon as
        // it has a fixed height.
        Spacer().frame(height: .DS.Padding.double)
            .accumulateIntrinsicHeight()

        if !(isKeyboardPresented && vertcalSizeClass == .compact) {
            saveButton()
                .padding(.horizontal, .DS.Padding.large)
                .padding(.bottom, .DS.Padding.double)
                .accumulateIntrinsicHeight()
        }
    }

    private func saveButton() -> some View {
        ZStack {
            Button {
                Task {
                    isSaving = true
                    if let profile = await self.model.saveAboutInfo(for: fields) {
                        aboutUpdateHandler?(profile)
                    }
                    isSaving = false
                }
            } label: {
                CTAButtonView(Localized.saveButtonTitle)
            }
            .disabled(!model.hasUnsavedChanges || isSaving)
            if isSaving {
                ProgressView()
            }
        }
    }

    @ViewBuilder
    private func personalInfoContent() -> some View {
        if fields.hasMultipleCategories(containing: .personalFields) {
            sectionHeader(title: Localized.personalSectionHeaderText)
        }

        if fields.contains(.displayName) {
            inputField(
                for: AboutInfoField.displayName.localizedName(),
                value: $model.aboutInfoModel.displayName
            )
        }
        if fields.contains(.aboutMe) {
            inputField(
                for: AboutInfoField.aboutMe.localizedName(),
                footerText: AttributedString(Localized.aboutMeFooterText),
                value: $model.aboutInfoModel.aboutMe,
                isLarge: true
            )
        }
        if fields.contains(.pronunciation) {
            inputField(
                for: AboutInfoField.pronunciation.localizedName(),
                footerText: AttributedString(Localized.pronunciationFooterText),
                value: $model.aboutInfoModel.pronunciation
            )
        }
        if fields.contains(.pronouns) {
            inputField(
                for: AboutInfoField.pronouns.localizedName(),
                value: $model.aboutInfoModel.pronouns
            )
        }
        if fields.contains(.location) {
            inputField(
                for: AboutInfoField.location.localizedName(),
                value: $model.aboutInfoModel.location
            )
        }
    }

    @ViewBuilder
    private func professionalInfoContent() -> some View {
        if fields.hasMultipleCategories(containing: .professionalFields) {
            sectionHeader(title: Localized.professionalSectionHeaderText)
        }
        if fields.contains(.jobTitle) {
            inputField(
                for: AboutInfoField.jobTitle.localizedName(),
                value: $model.aboutInfoModel.jobTitle
            )
        }
        if fields.contains(.company) {
            inputField(
                for: AboutInfoField.company.localizedName(),
                value: $model.aboutInfoModel.company
            )
        }
    }

    @ViewBuilder
    private func extraFieldsContent() -> some View {
        if fields.hasMultipleCategories(containing: .extraFields) {
            sectionHeader(title: Localized.extraSectionHeaderText)
        }
        if fields.hasExtraFields {
            Text(Localized.extraSectionNoticeText)
                .font(Constants.footerFont)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                .padding(.bottom)
        }
        if fields.contains(.firstName) {
            inputField(
                for: AboutInfoField.firstName.localizedName(),
                value: $model.aboutInfoModel.firstName
            )
        }
        if fields.contains(.lastName) {
            inputField(
                for: AboutInfoField.lastName.localizedName(),
                value: $model.aboutInfoModel.lastName
            )
        }
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(Constants.sectionHeaderFont)
            .multilineTextAlignment(.leading)
            .padding(.bottom, .DS.Padding.single)
    }

    private func inputField(
        for title: String,
        footerText: AttributedString? = nil,
        value: Binding<String>,
        isLarge: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: .DS.Padding.single) {
            Text(title)
                .font(Constants.primaryFont)
                .multilineTextAlignment(.leading)
            if isLarge {
                TextEditor(text: value)
                    .font(Constants.primaryFont)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, .DS.Padding.single)
                    .padding(.vertical, 0)
                    .inputBorders(colorScheme: colorScheme)
                    .frame(height: dynamicTypeSize >= .accessibility1 ? 150 : 120)
                    .disabled(isSaving)
            } else {
                TextField(
                    "",
                    text: value
                )
                .font(Constants.primaryFont)
                .padding(.DS.Padding.split)
                .inputBorders(colorScheme: colorScheme)
                .disabled(isSaving)
            }

            if let footerText {
                Text(footerText)
                    .font(Constants.footerFont)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
            }
        }
        .padding(.vertical, .DS.Padding.single)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func errorView(with error: any Error) -> some View {
        ScopeLoadingErrorView(
            error: error,
            isPresented: $isPresented,
            model: model, tokenErrorHandler: tokenErrorHandler
        )

        Spacer()
            .frame(height: Constants.vStackVerticalSpacing)
    }

    private enum Localized {
        static let aboutMeFooterText = SDKLocalizedString(
            "Profile.AboutInfoField.aboutMe.footer",
            value: "Brief description for your profile.",
            comment: "Description for the 'About me' field in the profile editing screen."
        )
        static let pronunciationFooterText = SDKLocalizedString(
            "Profile.AboutInfoField.pronunciation.footer",
            value: "Let them know how your name sounds like.",
            comment: "Description for the 'Pronunciation' field in the profile editing screen."
        )
        static let personalSectionHeaderText = SDKLocalizedString(
            "Profile.Section.Personal.header",
            value: "Personal",
            comment: "Title of the personal info section in the profile editing screen."
        )
        static let professionalSectionHeaderText = SDKLocalizedString(
            "Profile.Section.Professional.header",
            value: "Professional",
            comment: "Title of the professional/work info section in the profile editing screen."
        )
        static let extraSectionHeaderText = SDKLocalizedString(
            "Profile.Section.Extra.header",
            value: "Extras",
            comment: "Title of the 'Extra' fields group section in the About Info editing screen."
        )
        static let extraSectionNoticeText = SDKLocalizedString(
            "Profile.Section.Extra.notice",
            value: "This information will not appear on your Gravatar Web Profile, but other apps and services can use it.",
            comment: "Notice text for the 'Extra' fields group section in the About Info editing screen."
        )
        static let saveButtonTitle = SDKLocalizedString(
            "Profile.Save.title",
            value: "Save",
            comment: "Title of the button to save changes in the profile editing screen."
        )
    }
}

extension View {
    fileprivate func inputBorders(colorScheme: ColorScheme) -> some View {
        self.shape(
            RoundedRectangle(cornerRadius: 2),
            borderColor: Color(uiColor: .label).opacity(colorScheme == .dark ? 0.30 : 0.15),
            borderWidth: 1
        )
    }
}

#Preview {
    AboutEditorView(isPresented: .constant(true), model: .init(avatarImageModels: []), fields: .all)
}

#Preview("professional") {
    AboutEditorView(isPresented: .constant(true), model: .init(avatarImageModels: []), fields: .professionalFields)
}

#Preview("personal") {
    AboutEditorView(isPresented: .constant(true), model: .init(avatarImageModels: []), fields: .personalFields)
}
