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
        URLQueryItem(name: "!*'();:@&=+$,/?%#[]", value: "name_uses_reserved_chars"),
    ]

    private static let urlString = "https://example.com"

    private enum URLEncodedQuery {
        static let spacesQuery = "spaces=value%20with%20spaces"
        static let plusSignQuery = "plus_signs=value%2Bwith%2Bplus%2Bsigns"
        static let nonReservedChars = "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        static let reservedChars = "reserved_chars=%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D"
        static let nameUsesReservedChars = "%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D=name_uses_reserved_chars"

        static var queryString: String {
            "\(spacesQuery)&\(plusSignQuery)&\(nonReservedChars)&\(reservedChars)&\(nameUsesReservedChars)"
        }

        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
    }

    private enum DefaultEncodedQuery {
        static let spacesQuery = "spaces=value%20with%20spaces"
        static let plusSignQuery = "plus_signs=value+with+plus+signs"
        static let nonReservedChars = "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        static let reservedChars = "reserved_chars=!*'();:@%26%3D+$,/?%25%23%5B%5D"
        static let nameUsesReservedChars = "!*'();:@%26%3D+$,/?%25%23%5B%5D=name_uses_reserved_chars"

        static var queryString: String {
            "\(spacesQuery)&\(plusSignQuery)&\(nonReservedChars)&\(reservedChars)&\(nameUsesReservedChars)"
        }

        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
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

    func testSetQueryItemsWithEmptyArrayWithPercentEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems([], urlEncodedValues: true)

        XCTAssertNotNil(sut)
        XCTAssertNil(sut?.queryItems)
    }

    func testSetQueryItemsWithEmptyArrayWithoutPercentEncoding() {
        let components = URLComponents(string: Self.urlString)
        let sut = components?.withQueryItems([], urlEncodedValues: false)

        XCTAssertNotNil(sut)
        XCTAssertNil(sut?.queryItems)
    }
}
