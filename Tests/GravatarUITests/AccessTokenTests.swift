@testable import GravatarUI
import XCTest

class AccessTokenTests: XCTestCase {
    func testValidAccessTokenWithAllParameters() {
        // Given a valid callback URL with all parameters
        let token = "abc123"
        let url = URL(string: "https://example.com/callback#access_token=\(token)")!

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then the access token should be parsed correctly
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.token, token)
    }

    func testInvalidAccessTokenWithMissingAccessToken() {
        // Given a callback URL missing the access_token
        let url = URL(string: "https://example.com/callback#foo=bar&baz=qux")!

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then the initializer should return nil since access_token is required
        XCTAssertNil(accessToken)
    }

    func testAccessTokenWithSpecialCharacters() {
        // Given a callback URL with an access_token containing the literal character `&`
        // and additional fields separated by the special character `&`
        let token = "abc&123"
        let encodedToken = "abc%26123"
        let url = URL(string: "https://example.com/callback#access_token=\(encodedToken)&baz=qux&foo=bar")!

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then access_token should correctly decode special characters
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.token, token) // `%26` should decode to `&`
    }

    func testUrlGenerator() {}
}
