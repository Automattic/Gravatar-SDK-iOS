import XCTest

final class URLComponentsTests: XCTestCase {
    private static let urlString = "https://example.com"

    private let testQueryItems: TestQueryItems = .init(
        [
            TestQueryItem(
                name: "spaces",
                value: "value with spaces",
                plusEncodedQueryString: "spaces=value%20with%20spaces",
                defaultEncodedQueryString: "spaces=value%20with%20spaces"
            ),
            TestQueryItem(
                name: "plus_signs",
                value: "value+with+plus+signs",
                plusEncodedQueryString: "plus_signs=value%2Bwith%2Bplus%2Bsigns", // `+` should be encoded as `%2B`
                defaultEncodedQueryString: "plus_signs=value+with+plus+signs" // `+` should not be encoded
            ),
            TestQueryItem(
                name: "non_reserved_chars",
                value: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~",
                plusEncodedQueryString: "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~",
                defaultEncodedQueryString: "non_reserved_chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
            ),
            TestQueryItem(
                name: "reserved_chars",
                value: "!*'();:@&=+$,/?%#[]",
                plusEncodedQueryString: "reserved_chars=!*'();:@%26%3D%2B$,/?%25%23%5B%5D", // `+` should be encoded as `%2B`
                defaultEncodedQueryString: "reserved_chars=!*'();:@%26%3D+$,/?%25%23%5B%5D" // `+` should not be encoded
            ),
            TestQueryItem(
                name: "!*'();:@&=+$,/?%#[] ",
                value: "name_uses_reserved_chars",
                plusEncodedQueryString: "!*'();:@%26%3D%2B$,/?%25%23%5B%5D%20=name_uses_reserved_chars", // `+` should be encoded as `%2B`
                defaultEncodedQueryString: "!*'();:@%26%3D+$,/?%25%23%5B%5D%20=name_uses_reserved_chars" // `+` should not be encoded
            ),
            TestQueryItem(
                name: "non_ascii_chars",
                value: "नमस्ते दुनिया 👋🌍 ∑(n=1)^∞ (1/2)^n = 1",
                plusEncodedQueryString: "non_ascii_chars=%E0%A4%A8%E0%A4%AE%E0%A4%B8%E0%A5%8D%E0%A4%A4%E0%A5%87%20%E0%A4%A6%E0%A5%81%E0%A4%A8%E0%A4%BF%E0%A4%AF%E0%A4%BE%20%F0%9F%91%8B%F0%9F%8C%8D%20%E2%88%91(n%3D1)%5E%E2%88%9E%20(1/2)%5En%20%3D%201",
                defaultEncodedQueryString: "non_ascii_chars=%E0%A4%A8%E0%A4%AE%E0%A4%B8%E0%A5%8D%E0%A4%A4%E0%A5%87%20%E0%A4%A6%E0%A5%81%E0%A4%A8%E0%A4%BF%E0%A4%AF%E0%A4%BE%20%F0%9F%91%8B%F0%9F%8C%8D%20%E2%88%91(n%3D1)%5E%E2%88%9E%20(1/2)%5En%20%3D%201"
            ),
        ]
    )

    func testUrlComponentsEncodesPlusCharInQueryItems() {
        var components = URLComponents(string: Self.urlString)
        components = components?.settingQueryItems(testQueryItems.queryItems, shouldEncodePlusChar: true)

        XCTAssertEqual(components?.url, testQueryItems.plusEncodedURL)
    }

    func testUrlComponentsDoesNotEncodePlusCharInQueryItems() {
        var components = URLComponents(string: Self.urlString)
        components = components?.settingQueryItems(testQueryItems.queryItems, shouldEncodePlusChar: false)

        XCTAssertEqual(components?.url, testQueryItems.defaultEncodedURL)
    }

    func testEncodingPlusCharDoesNotAlterQueryItems() {
        var components = URLComponents(string: Self.urlString)
        components = components?.settingQueryItems(testQueryItems.queryItems, shouldEncodePlusChar: true)

        XCTAssertNotNil(components?.queryItems)
        XCTAssertEqual(components?.queryItems, testQueryItems.queryItems)
    }

    func testAddingEmptyQueryItemsArrayReturnsQueryItemsSetToNil() {
        let baseComponents = URLComponents(string: Self.urlString)
        let componentsWithQueryItems = baseComponents?.settingQueryItems(testQueryItems.queryItems, shouldEncodePlusChar: true)
        XCTAssertNotNil(componentsWithQueryItems?.queryItems, "URLComponents object should contain array of URLQueryItems")

        let componentsWithoutQueryItems = componentsWithQueryItems?.settingQueryItems([], shouldEncodePlusChar: true)
        XCTAssertNil(componentsWithoutQueryItems?.queryItems, "QueryItems should be nil")
    }
}

private struct TestQueryItems {
    let items: [TestQueryItem]

    var queryItems: [URLQueryItem] {
        items.map(\.queryItem)
    }

    var plusEncodedQueryString: String {
        items.map(\.plusEncodedQueryString).joined(separator: "&")
    }

    var defaultEncodedQueryString: String {
        items.map(\.defaultEncodedQueryString).joined(separator: "&")
    }

    var plusEncodedURL: URL? {
        URL(string: "\(TestQueryItem.urlString)?\(plusEncodedQueryString)")
    }

    var defaultEncodedURL: URL? {
        URL(string: "\(TestQueryItem.urlString)?\(defaultEncodedQueryString)")
    }

    init(_ items: [TestQueryItem]) {
        self.items = items
    }
}

private struct TestQueryItem {
    static let urlString = "https://example.com"

    let name: String
    let value: String
    let plusEncodedQueryString: String
    let defaultEncodedQueryString: String

    var queryItem: URLQueryItem {
        URLQueryItem(name: name, value: value)
    }
}
