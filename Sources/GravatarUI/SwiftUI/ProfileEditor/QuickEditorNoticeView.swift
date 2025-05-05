import Gravatar
import SwiftUI

@MainActor
struct QuickEditorNoticeView: View {
    let email: Email
    @Binding var token: String?
    @Binding var oauthError: OAuthError?
    @ObservedObject var model: AvatarPickerViewModel
    @Binding var safariURL: IdentifiableURL?
    let proceedAction: @MainActor () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if shouldShowIntro {
                VStack(alignment: .leading, spacing: 0) {
                    Text(QuickEditorConstants.Localized.MissingToken.headline)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(UIColor.label))

                    Text(String(format: QuickEditorConstants.Localized.MissingToken.subheadline, BundleInfo.appName ?? ""))
                        .font(.footnote)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.top, .DS.Padding.half)
                }
                .padding(.top, .DS.Padding.split)
                .padding(.bottom, .DS.Padding.split)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                EmailText(email: email)
            }
            AvatarPickerProfileViewWrapper(
                avatarID: $model.avatarIdentifier,
                forceRefreshAvatar: $model.forceRefreshAvatar,
                model: $model.profileModel,
                isLoading: $model.isProfileLoading,
                safariURL: $safariURL,
                buttonsMode: .constant(.none)
            )
            .padding(.top, AvatarPicker.Constants.profileViewTopSpacing / 2)
            .padding(.bottom, AvatarPicker.Constants.vStackVerticalSpacing)
            ContentLoadingErrorView(
                title: QuickEditorConstants.ErrorView.title(for: oauthError),
                subtext: QuickEditorConstants.ErrorView.subtext(for: oauthError),
                image: nil,
                actionButton: {
                    Button {
                        proceedAction()
                    } label: {
                        CTAButtonView(QuickEditorConstants.ErrorView.buttonTitle(for: oauthError))
                    }
                },
                innerPadding: .init(
                    top: .DS.Padding.double,
                    leading: .DS.Padding.double,
                    bottom: .DS.Padding.double,
                    trailing: .DS.Padding.double
                )
            )
            .padding(.bottom, .DS.Padding.double)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    var shouldShowIntro: Bool {
        switch oauthError {
        case .loggedInWithWrongEmail:
            false
        default:
            token == nil
        }
    }
}

#Preview {
    QuickEditorNoticeView(
        email: .init("some@email.com"),
        token: .constant("atoken"),
        oauthError: .constant(nil),
        model: .init(
            email: .init("some@email.com"),
            authToken: "atoken"
        ),
        safariURL: .constant(nil),
        proceedAction: {}
    )
}
