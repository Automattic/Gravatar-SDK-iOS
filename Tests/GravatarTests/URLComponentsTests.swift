import XCTest

final class URLComponentsTests: XCTestCase {
    private let url = "https://example.com"
    private let queryItems = [
        URLQueryItem(name: "spaces", value: "value with spaces"),
        URLQueryItem(name: "plus_signs", value: "value+with+plus+signs"),
        URLQueryItem(name: "special_chars", value: "!#$&'()*+,/:;=?@[]"),
    ]

    func testURLComponentsEncodingBehaviorMatchesDefaultBehavior() {
        var reference = URLComponents(string: url)
        reference?.queryItems = queryItems

        let sut = URLComponents(string: url, queryItems: queryItems, percentEncodedValues: false)

        XCTAssertEqual(sut?.url, reference?.url)
    }

    func testURLComponentsEncodingBehaviorEncodesSpecialCharacters() {
        let spaces_query = "spaces=value%20with%20spaces"
        let plus_sign_query = "plus_signs=value%2Bwith%2Bplus%2Bsigns"
        let special_chars = "special_chars=%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D"

        let reference = URL(string: "\(url)?\(spaces_query)&\(plus_sign_query)&\(special_chars)")

        let sut = URLComponents(string: url, queryItems: queryItems, percentEncodedValues: true)

        XCTAssertEqual(sut?.url, reference)
    }
}
