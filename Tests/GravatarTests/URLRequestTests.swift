@testable import Gravatar
import XCTest

final class URLRequestTests: XCTestCase {
    private let url = URL(string: "https://fake.url")!
    private let acceptLanguageHeaderName = "Accept-Language"
    private let mockLanguagePreferencePovider = MockLanguagePreferenceProvider(
        maxPreferredLanguages: 6,
        preferredLanguages: [ // One more than `maxPreferredLanguages`
            "en",
            "fr",
            "jp",
            "quenyan",
            "sindarin",
            "dwarven",
            "mordor",
        ]
    )

    func testSettingAcceptLanguageToFrench() throws {
        let encoding = "fr"
        let urlRequest = URLRequest(url: url).settingAcceptLanguage(encoding)

        try urlRequest.expect(header: acceptLanguageHeaderName, withValue: encoding)
    }

    func testSettingAcceptLanguageUsingPreferredLanguages() throws {
        let urlRequest = URLRequest(url: url).settingDefaultAcceptLanguage(languagePreferenceProvider: mockLanguagePreferencePovider)

        try urlRequest.expect(
            header: acceptLanguageHeaderName,
            withValue: mockLanguagePreferencePovider.qualityEncodedString
        )
    }

    func testQualityEncoding() {
        let preferredLanguages = ["en", "fr", "jp", "quenyan", "sindarin", "dwarven"]
        let qualityEncodedReference = "en, fr;q=0.9, jp;q=0.8, quenyan;q=0.7, sindarin;q=0.6, dwarven;q=0.5"
        XCTAssertEqual(preferredLanguages.qualityEncoded(), qualityEncodedReference)
    }
}

extension URLRequest {
    fileprivate func expect(
        header: String,
        withValue expectedValue: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let headerValue = try XCTUnwrap(self.value(forHTTPHeaderField: header), "Header 'header' should be set")
        XCTAssertEqual(headerValue, expectedValue, "Header value: \(headerValue) does not match the expected value: \(expectedValue)", file: file, line: line)
    }
}

private struct MockLanguagePreferenceProvider: LanguagePreferenceProvider {
    var maxPreferredLanguages: Int
    let preferredLanguages: [String]

    var qualityEncodedString: String {
        preferredLanguages.prefix(maxPreferredLanguages).qualityEncoded()
    }
}
