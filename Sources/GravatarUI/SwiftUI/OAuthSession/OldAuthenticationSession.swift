@preconcurrency import AuthenticationServices

final class WebAuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding, Sendable {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

actor OldAuthenticationSession: Sendable {
    let context = WebAuthenticationPresentationContextProvider()
    var session: ASWebAuthenticationSession?

    func authenticate(using url: URL, callbackURLScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let callbackURL {
                    continuation.resume(returning: callbackURL)
                }
            }

            Task { @MainActor in
                await session?.presentationContextProvider = context
                await session?.start()
            }
        }
    }

    nonisolated
    func cancel() {
        Task { @MainActor in
            await session?.cancel()
        }
    }
}
