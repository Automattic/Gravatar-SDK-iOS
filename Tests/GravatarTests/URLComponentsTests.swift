import XCTest

final class URLComponentsTests: XCTestCase {
    private let queryItems = [
        URLQueryItem(name: "spaces", value: "value with spaces"),
        URLQueryItem(name: "plus_signs", value: "value+with+plus+signs"),
        URLQueryItem(name: "special_chars", value: "!#$&'()*+,/:;=?@[]"),
    ]

    private static let urlString = "https://example.com"

    private enum PlusSignLiteralEncodedQuery {
        static let spaces_query = "spaces=value%20with%20spaces"
        static let plus_sign_query = "plus_signs=value%2Bwith%2Bplus%2Bsigns"
        static let special_chars = "special_chars=!%23$%26'()*%2B,/:;%3D?@%5B%5D"

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

    func testSetQueryItemsWithUrlEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems(queryItems, plusSignLiteralEncoded: true)

        let reference = PlusSignLiteralEncodedQuery.url

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithoutUrlEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems(queryItems, plusSignLiteralEncoded: false)

        let reference = DefaultEncodedQuery.url

        XCTAssertEqual(sut?.url, reference)
    }

    func testSetQueryItemsWithEmptyArray() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems([], plusSignLiteralEncoded: false)

        XCTAssertNotNil(sut)
        XCTAssertNil(sut?.queryItems)
    }
}
