@testable import Gravatar
@testable import GravatarUI
import TestHelpers
import XCTest

final class OAuthSessionTests: XCTestCase {
    private var mockSession: AuthenticationSessionMock!

    let email = Email("test@example.com")
    let successCallbackURL = URL(string: "https://example.com/callback#access_token=someCode")!
    let differentCallbackURL = URL(string: "https://example.com")!

    override func setUp() async throws {
        await Configuration.shared.configure(with: "", oauthSecrets: .init(clientID: "", redirectURI: ""))
        mockSession = AuthenticationSessionMock(authenticateCalledExpectation: expectation(description: "authenticateCalledExpectation"))
    }

    func testOAuthSuccessful() async throws {
        let session = try await startSession()
        let handled = try await handleURL(successCallbackURL, oauthSession: session)
        XCTAssertTrue(handled)
    }

    func testOAuthWillNotHandleURL() async throws {
        let session = try await startSession()
        let handled = try await handleURL(differentCallbackURL, oauthSession: session)
        XCTAssertFalse(handled)
    }

    func testOAuthWillSendFinishedNotification() async throws {
        let session = try await startSession()
        let notificationExpectation = expectation(forNotification: .authorizationFinished, object: nil)
        let handled = try await handleURL(successCallbackURL, oauthSession: session)
        XCTAssertTrue(handled)

        await fulfillment(of: [notificationExpectation], timeout: 0.5)
    }

    func testOAuthTokenRetrieved() async throws {
        let session = try await startSession()
        XCTAssertFalse(session.hasSession(with: email))

        let handled = try await handleURL(successCallbackURL, oauthSession: session)
        XCTAssertTrue(handled)
        XCTAssertTrue(session.hasSession(with: email))
    }

    func testOAuthWillSendErrorNotification() async throws {
        let session = try await startSession()
        let notificationExpectation = expectation(forNotification: .authorizationError, object: nil) { notification in
            guard let error = notification.object as? OAuthError else { return false }
            if case .loggedInWithWrongEmail = error { return true }
            return false
        }
        let handled = try await handleURL(successCallbackURL, oauthSession: session, isTokenAssociated: false)
        XCTAssertTrue(handled)

        await fulfillment(of: [notificationExpectation], timeout: 0.5)
    }

    func testOAuthHasExpiredToken() async throws {
        let session = try await startSession()
        let handled = try await handleURL(successCallbackURL, oauthSession: session)
        XCTAssertTrue(handled)

        XCTAssertTrue(session.hasSession(with: email))
        session.markSessionAsExpired(with: email)
        XCTAssertFalse(session.hasValidSession(with: email))
    }

    func testOAuthDeleteToken() async throws {
        let session = try await startSession()
        let handled = try await handleURL(successCallbackURL, oauthSession: session)
        XCTAssertTrue(handled)

        XCTAssertTrue(session.hasSession(with: email))
        session.deleteSession(with: email)
        XCTAssertFalse(session.hasSession(with: email))
    }
}

// MARK: - Helpers

extension OAuthSessionTests {
    func startSession() async throws -> OAuthSession {
        let session = OAuthSession(authenticationSession: mockSession, storage: TestStorage())
        let email = email
        Task {
            try await session.retrieveAccessToken(with: email)
        }
        // Wait until the session auth request starts from within the previous Task.
        // This simulates the WebView appearing on screen.
        // As is the case with `https` callback url schema, this task will not return until the session is cancelled.
        await fulfillment(of: [mockSession.authenticateCalledExpectation], timeout: 0.5)

        return session
    }

    func handleURL(_ url: URL, oauthSession: OAuthSession, isTokenAssociated: Bool = true) async throws -> Bool {
        // Hidding some complexity of this call to make it easier to read.
        try await OAuthSession.handleCallback(
            url,
            shared: oauthSession,
            checkTokenAuthorizationService: checkTokenService(isAssociated: isTokenAssociated)
        )
    }

    private func checkTokenService(isAssociated: Bool = true) throws -> CheckTokenAuthorizationService {
        let response = AssociatedResponse(associated: isAssociated)
        let data = try JSONEncoder().encode(response)

        return CheckTokenAuthorizationService(session: URLSessionMock(returnData: data, response: .successResponse()))
    }
}

// MARK: - Helper classes

private class AuthenticationSessionMock: AuthenticationSession, @unchecked Sendable {
    var task: Task<Void, Error>? = .init {
        repeat {
            try? await Task.sleep(nanoseconds: 100_000)
        } while true
    }

    var authenticateCalledExpectation: XCTestExpectation

    func cancel() async {
        task?.cancel()
    }

    init(authenticateCalledExpectation: XCTestExpectation) {
        self.authenticateCalledExpectation = authenticateCalledExpectation
    }

    func authenticate(using url: URL, callbackURLScheme: String) async throws -> URL {
        authenticateCalledExpectation.fulfill()
        guard let _ = try await task?.value else {
            fatalError()
        }
        return URL(string: "some://url.com")! // we won't get that far
    }
}

final class TestStorage: SecureStorage {
    private var store: [String: KeychainToken] = [:]

    func setSecret(_ secret: GravatarUI.KeychainToken, for key: String) throws {
        store[key] = secret
    }

    func deleteSecret(with key: String) throws {
        store[key] = nil
    }

    func secret(with key: String) throws -> GravatarUI.KeychainToken? {
        store[key]
    }

    func cancel() async {}
}
