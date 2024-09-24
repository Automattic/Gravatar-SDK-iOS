@testable import GravatarUI
import XCTest

class AccessTokenTests: XCTestCase {
    func testValidAccessTokenWithAllParameters() {
        // Given a valid callback URL with all parameters
        let url = url(encodedAccessToken: "abc123", encodedExpiresIn: "3600", encodedTokenType: "bearer")

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then the access token should be parsed correctly
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.accessToken, "abc123")
        XCTAssertEqual(accessToken?.expiresIn, 3600)
        XCTAssertEqual(accessToken?.tokenType, "bearer")
    }

    func testValidAccessTokenWithMissingOptionalParameters() {
        // Given a callback URL with only the access_token
        let url = url(encodedAccessToken: "abc123")

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then only access_token should be present, expiresIn and tokenType should be nil
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.accessToken, "abc123")
        XCTAssertNil(accessToken?.expiresIn)
        XCTAssertNil(accessToken?.tokenType)
    }

    func testInvalidAccessTokenWithMissingAccessToken() {
        // Given a callback URL missing the access_token
        let url = url(encodedExpiresIn: "3600", encodedTokenType: "bearer")

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then the initializer should return nil since access_token is required
        XCTAssertNil(accessToken)
    }

    func testMalformedExpiresInParameter() {
        // Given a callback URL with a non-numeric expires_in value
        let url = url(encodedAccessToken: "abc123", encodedExpiresIn: "notANumber", encodedTokenType: "bearer")

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then accessToken should be valid, but expiresIn should be nil
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.accessToken, "abc123")
        XCTAssertNil(accessToken?.expiresIn) // expires_in should fail to convert to Int and be nil
        XCTAssertEqual(accessToken?.tokenType, "bearer")
    }

    func testAccessTokenWithSpecialCharacters() {
        // Given a callback URL with an access_token containing special characters
        let url = url(encodedAccessToken: "abc%26123", encodedExpiresIn: "3600", encodedTokenType: "bearer")

        // When initializing AccessToken from the URL
        let accessToken = AccessToken(from: url)

        // Then access_token should correctly decode special characters
        XCTAssertNotNil(accessToken)
        XCTAssertEqual(accessToken?.accessToken, "abc&123") // `%26` should decode to `&`
        XCTAssertEqual(accessToken?.expiresIn, 3600)
        XCTAssertEqual(accessToken?.tokenType, "bearer")
    }

    private func url(
        encodedAccessToken: String? = nil,
        encodedExpiresIn: String? = nil,
        encodedTokenType: String? = nil
    ) -> URL {
        var urlString = "https://example.com/callback#"

        if let encodedAccessToken {
            urlString += "access_token=\(encodedAccessToken)"
        }
        if let encodedExpiresIn {
            urlString += "&expires_in=\(encodedExpiresIn)"
        }

        if let encodedTokenType {
            urlString += "&token_type=\(encodedTokenType)"
        }

        return URL(string: urlString)!
    }
}
