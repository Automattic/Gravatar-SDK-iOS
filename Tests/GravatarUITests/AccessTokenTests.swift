@testable import GravatarUI
import XCTest

class AccessTokenTests: XCTestCase {
    func testValidAccessTokenWithAllParameters() {
        // Given a valid callback URL with all parameters
        let url = url(encodedAccessToken: "abc123")

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then the access token should be parsed correctly
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.token, "abc123")
    }

    func testInvalidAccessTokenWithMissingAccessToken() {
        // Given a callback URL missing the access_token
        let url = url(encodedAccessToken: nil)

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then the initializer should return nil since access_token is required
        XCTAssertNil(accessToken)
    }

    func testAccessTokenWithSpecialCharacters() {
        // Given a callback URL with an access_token containing special characters
        let url = url(encodedAccessToken: "abc%26123")

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then access_token should correctly decode special characters
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.token, "abc&123") // `%26` should decode to `&`
    }

    private func url(encodedAccessToken: String? = nil) -> URL {
        var urlString = "https://example.com/callback#"

        if let encodedAccessToken {
            urlString += "access_token=\(encodedAccessToken)"
        }

        return URL(string: urlString)!
    }
}
