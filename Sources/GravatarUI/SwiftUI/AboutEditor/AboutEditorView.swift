import SwiftUI

struct AboutEditorView: View {
    private enum Constants {
        static let primaryFont: Font = .subheadline
        static let sectionHeaderFont: Font = .subheadline.weight(.semibold)
        static let footerFont: Font = .footnote
        static let horizontalPadding: CGFloat = .DS.Padding.double
    }

    @State private var isSaving: Bool = false
    @Binding var isPresented: Bool
    @ObservedObject var model: AvatarPickerViewModel
    let fields: AboutInfoField
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var tokenErrorHandler: (() -> Void)?
    var aboutUpdateHandler: (() -> Void)?

    var body: some View {
        ZStack {
            VStack {
                if model.isProfileLoading {
                    LoadingIndicatorView()
                } else if let error = model.profileResult?.error() {
                    errorView(with: error)
                } else {
                    content()
                }
            }
            ToastContainerView(toastManager: model.toastManager)
                .padding(.horizontal, Constants.horizontalPadding * 2)
        }
    }

    @ViewBuilder
    private func content() -> some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    personalInfoContent()
                    if fields.hasMultipleCategories {
                        Spacer().frame(height: .DS.Padding.double)
                    }
                    professionalInfoContent()
                }
                .padding(.horizontal, .DS.Padding.double)
                .padding(.vertical, .DS.Padding.double)
            }
        }
        .avatarPickerBorder(colorScheme: colorScheme, borderWidth: 1)
        .padding(.horizontal, .DS.Padding.double)
        Spacer().frame(height: .DS.Padding.double)

        saveButton()
            .padding(.horizontal, .DS.Padding.large)
            .padding(.bottom, .DS.Padding.double)
    }

    private func saveButton() -> some View {
        ZStack {
            Button {
                Task {
                    isSaving = true
                    if await self.model.saveAboutInfo(for: fields) {
                        aboutUpdateHandler?()
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
        if fields.hasMultipleCategories {
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
                footerText: Localized.aboutMeFooterText,
                value: $model.aboutInfoModel.aboutMe,
                isLarge: true
            )
        }
        if fields.contains(.pronunciation) {
            inputField(
                for: AboutInfoField.pronunciation.localizedName(),
                footerText: Localized.pronunciationFooterText,
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
        if fields.hasMultipleCategories {
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

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(Constants.sectionHeaderFont)
            .multilineTextAlignment(.leading)
            .padding(.bottom, .DS.Padding.single)
    }

    private func inputField(
        for title: String,
        footerText: String? = nil,
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
            } else {
                TextField(
                    "",
                    text: value
                )
                .font(Constants.primaryFont)
                .padding(.DS.Padding.split)
                .inputBorders(colorScheme: colorScheme)
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
