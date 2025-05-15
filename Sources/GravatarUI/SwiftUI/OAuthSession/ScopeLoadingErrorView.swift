import SwiftUI

struct ScopeLoadingErrorView: View {
    let error: Error

    @Binding var isPresented: Bool
    @ObservedObject var model: AvatarPickerViewModel

    var closeSubtextLocalizedString: String = Localized.SessionExpired.Close.subtext
    var logInSubtextLocalizedString: String = Localized.SessionExpired.LogIn.subtext

    var tokenErrorHandler: (() -> Void)?

    var body: some View {
        VStack(alignment: .center) {
            switch error {
            case APIError.responseError(reason: let reason) where reason.httpStatusCode == HTTPStatus.unauthorized.rawValue:
                let buttonTitle = tokenErrorHandler == nil ?
                    Localized.SessionExpired.Close.buttonTitle :
                    Localized.SessionExpired.LogIn.buttonTitle
                let subtext: String = tokenErrorHandler == nil ? closeSubtextLocalizedString : logInSubtextLocalizedString
                contentLoadingErrorView(
                    title: Localized.SessionExpired.title,
                    subtext: subtext,
                    actionButton: {
                        Button {
                            if let tokenErrorHandler {
                                tokenErrorHandler()
                            } else {
                                isPresented = false
                            }
                        } label: {
                            CTAButtonView(buttonTitle)
                        }
                    }
                )
            case APIError.responseError(reason: let reason) where reason.isURLSessionError:
                let subtext: String = if let reason = reason.urlSessionErrorLocalizedDescription {
                    reason
                } else {
                    Localized.Retry.subtext
                }
                contentLoadingErrorView(
                    title: Localized.Retry.title,
                    subtext: subtext,
                    actionButton: {
                        Button {
                            model.refresh(modelToRefresh: .all)
                        } label: {
                            CTAButtonView(Localized.Retry.buttonTitle)
                        }
                    }
                )
            default:
                contentLoadingErrorView(
                    title: Localized.Retry.title,
                    subtext: Localized.Retry.subtext,
                    image: nil,
                    actionButton: {
                        Button {
                            model.refresh(modelToRefresh: .all)
                        } label: {
                            CTAButtonView(Localized.Retry.buttonTitle)
                        }
                    }
                )
            }
        }
        .foregroundColor(.secondary)
    }

    @MainActor
    private func contentLoadingErrorView(
        title: String,
        subtext: String,
        image: Image? = nil,
        actionButton: @escaping () -> some View
    ) -> some View {
        ContentLoadingErrorView(
            title: title,
            subtext: subtext,
            image: image,
            actionButton: actionButton,
            innerPadding: .init(
                top: .DS.Padding.double,
                leading: Constants.horizontalPadding,
                bottom: .DS.Padding.double,
                trailing: Constants.horizontalPadding
            )
        )
        .padding(.horizontal, Constants.horizontalPadding)
    }
}

private enum Constants {
    static let horizontalPadding: CGFloat = .DS.Padding.double
}

private enum Localized {
    enum SessionExpired {
        static let title = SDKLocalizedString(
            "AvatarPicker.ContentLoading.Failure.SessionExpired.title",
            value: "Session expired",
            comment: "Title of a message advising the user that their login session has expired."
        )

        enum Close {
            static let buttonTitle = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.SessionExpired.Close.buttonTitle",
                value: "Close",
                comment: "Title of a button that will close the Avatar Picker, appearing beneath a message that advises the user that their login session has expired."
            )

            static let subtext = SDKLocalizedString(
                "ProfileEditor.ContentLoading.Failure.SessionExpired.Close.subtext",
                value: "Sorry, it looks like your session has expired. Make sure you're logged in to update your Profile.",
                comment: "A message describing the error and advising the user to login again to resolve the issue"
            )
        }

        enum LogIn {
            static let buttonTitle = SDKLocalizedString(
                "AvatarPicker.ContentLoading.Failure.SessionExpired.LogIn.buttonTitle",
                value: "Log in",
                comment: "Title of a button that will begin the process of authenticating the user, appearing beneath a message that advises the user that their login session has expired."
            )

            static let subtext = SDKLocalizedString(
                "ProfileEditor.ContentLoading.Failure.SessionExpired.LogIn.subtext",
                value: "Session expired for security reasons. Please log in to update your Profile.",
                comment: "A message describing the error and advising the user to login again to resolve the issue"
            )
        }
    }

    enum Retry {
        static let title = SDKLocalizedString(
            "AvatarPicker.ContentLoading.Failure.Retry.title",
            value: "Ooops",
            comment: "Title of a message advising the user that something went wrong while loading their avatars"
        )
        static let subtext = SDKLocalizedString(
            "AvatarPicker.ContentLoading.Failure.Retry.subtext",
            value: "Something went wrong and we couldn’t connect to Gravatar servers.",
            comment: "A message asking the user to try again"
        )
        static let buttonTitle = SDKLocalizedString(
            "AvatarPicker.Upload.Error.Retry.title",
            value: "Retry",
            comment: "The title of the retry button on the upload error dialog."
        )
    }
}
