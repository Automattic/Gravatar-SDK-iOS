@testable import GravatarUI
import XCTest

final class OAuthSessionTests: XCTestCase {
    func testOAuth() {
        let mockSession = AuthenticationSessionMock(responseURL: URL(string: "some://url.com?code=someCode")!)
        let _ = OAuthSession(authenticationSession: mockSession)
    }
}

class AuthenticationSessionMock: AuthenticationSession, @unchecked Sendable {
    func cancel() async {}

    let responseURL: URL

    init(responseURL: URL) {
        self.responseURL = responseURL
    }

    func authenticate(using url: URL, callbackURLScheme: String) async throws -> URL {
        responseURL
    }
}
