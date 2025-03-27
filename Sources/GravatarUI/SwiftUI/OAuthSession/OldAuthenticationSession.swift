@preconcurrency import AuthenticationServices

extension OldAuthenticationSession: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

final class OldAuthenticationSession: NSObject, Sendable {
    private let sessionStorage = SessionStorage()

    func authenticate(using url: URL, callbackURLComponents: URLComponents) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session: ASWebAuthenticationSession
            let completionHandler = authSessionCompletionHandler(with: continuation)

            if #available(iOS 17.4, *) {
                let callback = authSessionCallback(with: callbackURLComponents)
                session = ASWebAuthenticationSession(
                    url: url,
                    callback: callback,
                    completionHandler: completionHandler
                )
            } else {
                session = ASWebAuthenticationSession(
                    url: url,
                    callbackURLScheme: callbackURLComponents.scheme,
                    completionHandler: completionHandler
                )
            }

            Task { @MainActor in
                await sessionStorage.save(session)
                session.presentationContextProvider = self
                session.prefersEphemeralWebBrowserSession = true
                session.start()
            }
        }
    }

    func cancel() {
        Task { @MainActor in
            guard let session = await sessionStorage.restore() else { return }
            session.cancel()
        }
    }

    @available(iOS 17.4, *)
    private func authSessionCallback(with components: URLComponents) -> ASWebAuthenticationSession.Callback {
        if components.scheme == "https", let host = components.host {
            .https(host: host, path: components.path)
        } else {
            .customScheme(components.scheme ?? "")
        }
    }

    private func authSessionCompletionHandler(with continuation: CheckedContinuation<URL, any Error>) -> ASWebAuthenticationSession.CompletionHandler {
        { callbackURL, error in
            if let error {
                continuation.resume(throwing: error)
            } else if let callbackURL {
                continuation.resume(returning: callbackURL)
            }
        }
    }
}

// `ASWebAuthenticationSession` is not thread safe. `SessionStorage` helps to silence some warnings (Swift 6 errors),
// but we are still importing `AuthenticationServices` as `@preconcurrency`.
// On the other hand, there won't be more than one attempt of oauth at a time, which reduces possible concurrency issues.
private actor SessionStorage {
    var current: ASWebAuthenticationSession?

    func save(_ session: ASWebAuthenticationSession) {
        current = session
    }

    func restore() -> ASWebAuthenticationSession? {
        let currentSession = current
        return currentSession
    }
}
