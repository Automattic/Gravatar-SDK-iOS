@preconcurrency import AuthenticationServices

final class WebAuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding, Sendable {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

struct OldAuthenticationSession: Sendable {
    let context = WebAuthenticationPresentationContextProvider()

    func authenticate(using url: URL, callbackURLScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                }
            }

            Task { @MainActor in
                session.presentationContextProvider = context
                session.start()
            }
        }
    }
}
