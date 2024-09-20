import Foundation

extension URLRequest {
    /// Returns a `URLRequest` with the `Accept-Language` header set using the provided `value`
    ///
    /// To specify the user's preferred languages, use `settingDefaultAcceptLanguage()`
    ///
    /// - Parameter value: The `Accept-Language` value.
    /// - Returns: `URLRequest` with the `Accept-Language` header set
    func settingAcceptLanguage(_ value: String) -> URLRequest {
        self.settingHeader(value: value, forHTTPHeaderField: HTTPHeaderName.accceptLanguage)
    }

    /// Returns a `URLRequest` with a default `Accept-Language` header, generated by querying `Locale` for the user's
    /// `preferredLanguages`.
    ///
    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    ///
    /// - Parameter languagePreferenceProvider: an instance that conforms to `LanguagePreferenceProvider`
    /// - Returns: `URLRequest` with the `Accept-Language` header set to the user's preferred languages
    func settingDefaultAcceptLanguage(languagePreferenceProvider: LanguagePreferenceProvider = SystemLanguagePreferenceProvider()) -> URLRequest {
        settingAcceptLanguage(
            languagePreferenceProvider.preferredLanguages.prefix(
                languagePreferenceProvider.maxPreferredLanguages
            ).qualityEncoded()
        )
    }

    func settingHeader(value: String, forHTTPHeaderField httpHeaderField: String) -> URLRequest {
        var copy = self
        copy.setValue(value, forHTTPHeaderField: httpHeaderField)
        return copy
    }
}

extension URLRequest {
    enum HTTPHeaderName {
        static let authorization = "Authorization"
        static let accceptLanguage = "Accept-Language"
    }
}

extension Collection<String> {
    /// Returns a string that can be used as the value of an `Accept-Language` header.
    ///
    /// ## Example
    ///
    /// `[da, en-gb, en]` --> `"da, en-gb;q=0.9, en;q=0.8"`
    ///
    /// Which means:
    /// "I prefer Danish, but will accept British English and other types of English"
    ///
    /// See the [Accept-Language HTTP header documentation](https://tools.ietf.org/html/rfc7231#section-5.3.5).
    ///
    /// - Returns: a `String` representing the preferred languages, to be used as the `value` of the `Accept-Language` header
    func qualityEncoded() -> String {
        self.enumerated().map { index, encoding in
            let qValue = 1.0 - (Double(index) * 0.1) // Decrease the q-value for each encoding
            return index == 0 ? encoding : "\(encoding);q=\(qValue)"
        }.joined(separator: ", ")
    }
}

private enum Constant {
    static let maxPreferredLanguages = 6
}

protocol LanguagePreferenceProvider {
    var preferredLanguages: [String] { get }
    var maxPreferredLanguages: Int { get }
}

struct SystemLanguagePreferenceProvider: LanguagePreferenceProvider {
    let maxPreferredLanguages = Constant.maxPreferredLanguages
    var preferredLanguages: [String] {
        Locale.preferredLanguages
    }
}
