import Foundation

extension URLComponents {
    /// Creates a `URLComponents` object from a string and an array `[URLQueryItem]`.
    ///
    /// The default behavior is to percent-encode all non-alpha-numeric characters in each value.  This differs
    /// from the default behavior of `URLComponents`.  By default, `URLComponents` doesn't encode any
    /// characters that are valid in a query. This can cause problems when query values contain character literals
    /// that are valid in a query, and won't be interpreted as a literal character.
    ///
    /// For example, the `+` sign is a valid character in a query.  If present, `URLComponents` will treat it as
    /// a valid character, and leave it unencoded.  If the value will be interpreted using the
    /// `application/x-www-form-urlencoded` specification, the `+` character will be interpreted as a space.
    ///
    /// - Parameters:
    ///   - string: The URL string
    ///   - queryItems: An array of `URLQueryItem`'s
    ///   - percentEncodedValues: Whether to fully percent-encode values.
    ///         Setting to `true` will fully encode all non-alpha-numeric characters.
    ///         Setting to `false` will encode all characters that are not valid in a url query
    package init?(string: String, queryItems: [URLQueryItem], percentEncodedValues: Bool = true) {
        if percentEncodedValues {
            self.init(
                string: string,
                queryItems: queryItems,
                queryItemEncodingAllowedCharacters: .alphanumerics
            )
        } else {
            self.init(string: string)
            self.queryItems = queryItems
        }
    }

    /// Returns a `URLComponents` with the `queryItems` set.
    ///
    /// - Parameters:
    ///   - queryItems: An array of `URLQueryItem`s
    ///   - percentEncodedValues: Whether to fully percent-encode values.
    ///         Setting to `true` will fully encode all non-alpha-numeric characters.
    ///         Setting to `false` will encode all characters that are not valid in a url query
    /// - Returns: `URLComponents` with the `queryItems` set with the specified encoding
    package func withQueryItems(_ queryItems: [URLQueryItem], percentEncodedValues: Bool = true) -> URLComponents {
        var copy = self

        if queryItems.isEmpty {
            copy.queryItems = nil
        } else if percentEncodedValues {
            copy.setQueryItems(queryItems, queryItemEncodingAllowedCharacters: .alphanumerics)
        } else {
            copy.queryItems = queryItems
        }

        return copy
    }
}

extension URLComponents {
    /// Creates a `URLComponents` object from a string and an array `[URLQueryItem]`.
    ///
    /// Use `queryItemEncodingAllowedCharacters` to specify the characters that should be allowed,
    /// and not percent-encoded.
    ///
    /// - Parameters:
    ///   - string: The URL string
    ///   - queryItems: An array of `URLQueryItems`s
    ///   - queryItemEncodingAllowedCharacters: The character set that should not be percent-encoded
    private init?(
        string: String,
        queryItems: [URLQueryItem],
        queryItemEncodingAllowedCharacters: CharacterSet
    ) {
        self.init(string: string)
        self.queryItems = []
        self.setQueryItems(queryItems, queryItemEncodingAllowedCharacters: queryItemEncodingAllowedCharacters)
    }

    private mutating func setQueryItems(
        _ queryItems: [URLQueryItem],
        queryItemEncodingAllowedCharacters: CharacterSet
    ) {
        self.percentEncodedQueryItems = queryItems.map { $0.percentEncoded(withAllowedCharacters: queryItemEncodingAllowedCharacters) }
    }
}

extension URLQueryItem {
    /// Returns a `URLQueryItem` whose value has been percent-encoded for the specified character set.
    ///
    /// A Percent-encoded `URLQueryItem` should only be assigned to `URLComponents.percentEncodedQueryItems`.
    /// It is a mistake to assign an encoded `URLQueryItem` to `URLComponents.queryItems`.
    /// If a percent-encoded `URLQueryItem` is assigned as a `.queryItem`, the encoded value will be double-encoded.
    ///
    /// - Parameter withAllowedCharacters: The character set that should not be percent-encoded
    /// - Returns: A `URLQueryItem` configured with the specified encoding
    fileprivate func percentEncoded(withAllowedCharacters: CharacterSet) -> URLQueryItem {
        /// `addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)` encode parameters following RFC 3986
        /// and it treats many special characters valid and leaves them unencoded.
        /// We need to "URL encode" all non-alphanumberic characters like "+", "@"... So we instead pass `.alphanumerics` here.
        var newQueryItem = self
        newQueryItem.value = value?
            .addingPercentEncoding(withAllowedCharacters: withAllowedCharacters)

        return newQueryItem
    }
}
