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
        URLQueryItem(name: "!*'();:@&=+$,/?%#[] ", value: "name_uses_reserved_chars"),
        URLQueryItem(name: "non_ascii_chars", value: "नमस्ते दुनिया 👋🌍 ∑(n=1)^∞ (1/2)^n = 1"),
    ]

    private static let urlString = "https://example.com"

    private enum PlusCharEncodedQuery {
        static let spacesQuery = "spaces=value%20with%20spaces"
        static let plusSignQuery = "plus_signs=value%2Bwith%2Bplus%2Bsigns"
        static let nonReservedChars = "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        static let reservedChars = "reserved_chars=!*'();:@%26%3D%2B$,/?%25%23%5B%5D"
        static let nameUsesReservedChars = "!*'();:@%26%3D%2B$,/?%25%23%5B%5D%20=name_uses_reserved_chars"
        static let nonASCIIChars =
            "non_ascii_chars=%E0%A4%A8%E0%A4%AE%E0%A4%B8%E0%A5%8D%E0%A4%A4%E0%A5%87%20%E0%A4%A6%E0%A5%81%E0%A4%A8%E0%A4%BF%E0%A4%AF%E0%A4%BE%20%F0%9F%91%8B%F0%9F%8C%8D%20%E2%88%91(n%3D1)%5E%E2%88%9E%20(1/2)%5En%20%3D%201"

        static var queryString: String {
            "\(spacesQuery)&\(plusSignQuery)&\(nonReservedChars)&\(reservedChars)&\(nameUsesReservedChars)&\(nonASCIIChars)"
        }

        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
    }

    private enum DefaultEncodedQuery {
        static let spacesQuery = "spaces=value%20with%20spaces"
        static let plusSignQuery = "plus_signs=value+with+plus+signs"
        static let nonReservedChars = "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        static let reservedChars = "reserved_chars=!*'();:@%26%3D+$,/?%25%23%5B%5D"
        static let nameUsesReservedChars = "!*'();:@%26%3D+$,/?%25%23%5B%5D%20=name_uses_reserved_chars"
        static let nonASCIIChars =
            "non_ascii_chars=%E0%A4%A8%E0%A4%AE%E0%A4%B8%E0%A5%8D%E0%A4%A4%E0%A5%87%20%E0%A4%A6%E0%A5%81%E0%A4%A8%E0%A4%BF%E0%A4%AF%E0%A4%BE%20%F0%9F%91%8B%F0%9F%8C%8D%20%E2%88%91(n%3D1)%5E%E2%88%9E%20(1/2)%5En%20%3D%201"

        static var queryString: String {
            "\(spacesQuery)&\(plusSignQuery)&\(nonReservedChars)&\(reservedChars)&\(nameUsesReservedChars)&\(nonASCIIChars)"
        }

        static var url: URL { URL(string: "\(urlString)?\(queryString)")! }
    }

    func testUrlComponentsEncodesPlusCharInQueryItems() {
        var components = URLComponents(string: Self.urlString)
        components = components?.settingQueryItems(queryItems, shouldEncodePlusChar: true)

        XCTAssertEqual(components?.url, PlusCharEncodedQuery.url)
    }

    func testUrlComponentsDoesNotEncodePlusCharInQueryItems() {
        var components = URLComponents(string: Self.urlString)
        components = components?.settingQueryItems(queryItems, shouldEncodePlusChar: false)

        XCTAssertEqual(components?.url, DefaultEncodedQuery.url)
    }

    func testEncodingPlusCharDoesNotAlterQueryItems() {
        var components = URLComponents(string: Self.urlString)
        components = components?.settingQueryItems(queryItems, shouldEncodePlusChar: true)

        XCTAssertNotNil(components?.queryItems)
        XCTAssertEqual(components?.queryItems, queryItems)
    }

    func testAddingEmptyQueryItemsArrayReturnsQueryItemsSetToNil() {
        let baseComponents = URLComponents(string: Self.urlString)
        let componentsWithQueryItems = baseComponents?.settingQueryItems(queryItems, shouldEncodePlusChar: true)
        XCTAssertNotNil(componentsWithQueryItems?.queryItems, "URLComponents object should contain array of URLQueryItems")

        let componentsWithoutQueryItems = componentsWithQueryItems?.settingQueryItems([], shouldEncodePlusChar: true)
        XCTAssertNil(componentsWithoutQueryItems?.queryItems, "QueryItems should be nil")
    }
}
