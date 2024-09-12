import XCTest

final class URLComponentsTests: XCTestCase {
    private let queryItems = [
        URLQueryItem(name: "spaces", value: "value with spaces"),
        URLQueryItem(name: "plus_signs", value: "value+with+plus+signs"),
        URLQueryItem(name: "special_chars", value: "!#$&'()*+,/:;=?@[]"),
    ]

    private static let urlString = "https://example.com"

    private enum FullyEncodedQuery {
        static let spaces_query = "spaces=value%20with%20spaces"
        static let plus_sign_query = "plus_signs=value%2Bwith%2Bplus%2Bsigns"
        static let special_chars = "special_chars=%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D"

        static var queryString: String { "\(spaces_query)&\(plus_sign_query)&\(special_chars)" }
        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
    }

    private enum DefaultEncodedQuery {
        static let spaces_query = "spaces=value%20with%20spaces"
        static let plus_sign_query = "plus_signs=value+with+plus+signs"
        static let special_chars = "special_chars=!%23$%26'()*+,/:;%3D?@%5B%5D"

        static var queryString: String { "\(spaces_query)&\(plus_sign_query)&\(special_chars)" }
        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
    }

    func testURLComponentsEncodingBehaviorMatchesDefaultBehavior() {
        var reference = URLComponents(string: Self.urlString)
        reference?.queryItems = queryItems

        let sut = URLComponents(string: Self.urlString, queryItems: queryItems, percentEncodedValues: false)

        XCTAssertEqual(sut?.url, reference?.url)
    }

    func testURLComponentsEncodingBehaviorEncodesSpecialCharacters() {
        let reference = FullyEncodedQuery.url

        let sut = URLComponents(string: Self.urlString, queryItems: queryItems, percentEncodedValues: true)

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithPercentEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems(queryItems, percentEncodedValues: true)

        let reference = FullyEncodedQuery.url

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithoutPercentEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems(queryItems, percentEncodedValues: false)

        let reference = DefaultEncodedQuery.url

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithEmptyArray() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems([], percentEncodedValues: false)

        XCTAssertNotNil(sut)
        XCTAssertNil(sut?.queryItems)
    }
}
