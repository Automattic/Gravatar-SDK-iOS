import XCTest

final class URLComponentsTests: XCTestCase {
    private let queryItems = [
        URLQueryItem(name: "spaces", value: "value with spaces"),
        URLQueryItem(name: "plus_signs", value: "value+with+plus+signs"),
        URLQueryItem(
            name: "non_reserved_chars",
            value: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        ),
        URLQueryItem(name: "reserved_chars", value: "!*'();:@&=+$,/?%#[]"),
    ]

    private static let urlString = "https://example.com"

    private enum URLEncodedQuery {
        static let spaces_query = "spaces=value%20with%20spaces"
        static let plus_sign_query = "plus_signs=value%2Bwith%2Bplus%2Bsigns"
        static let non_reserved_chars = "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        static let reserved_chars = "reserved_chars=%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D"

        static var queryString: String {
            "\(spaces_query)&\(plus_sign_query)&\(non_reserved_chars)&\(reserved_chars)"
        }

        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
    }

    private enum DefaultEncodedQuery {
        static let spaces_query = "spaces=value%20with%20spaces"
        static let plus_sign_query = "plus_signs=value+with+plus+signs"
        static let non_reserved_chars = "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        static let reserved_chars = "reserved_chars=!*'();:@%26%3D+$,/?%25%23%5B%5D"

        static var queryString: String {
            "\(spaces_query)&\(plus_sign_query)&\(non_reserved_chars)&\(reserved_chars)"
        }

        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
    }

    func testURLComponentsEncodingBehaviorMatchesDefaultBehavior() {
        var reference = URLComponents(string: Self.urlString)
        reference?.queryItems = queryItems

        let sut = URLComponents(string: Self.urlString, queryItems: queryItems, urlEncodedValues: false)

        XCTAssertEqual(sut?.url, reference?.url)
    }

    func testURLComponentsEncodingBehaviorEncodesSpecialCharacters() {
        let reference = URLEncodedQuery.url

        let sut = URLComponents(string: Self.urlString, queryItems: queryItems, urlEncodedValues: true)

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithPercentEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems(queryItems, urlEncodedValues: true)

        let reference = URLEncodedQuery.url

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithoutPercentEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems(queryItems, urlEncodedValues: false)

        let reference = DefaultEncodedQuery.url

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithEmptyArray() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems([], urlEncodedValues: false)

        XCTAssertNotNil(sut)
        XCTAssertNil(sut?.queryItems)
    }
}
