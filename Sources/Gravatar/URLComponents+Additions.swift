import Foundation

extension URLComponents {
    /// Returns a `URLComponents` with the `queryItems` set and optinally encoded.
    ///
    /// - Parameters:
    ///   - queryItems: An array of `URLQueryItem`s
    ///   - urlEncodedValues: Whether to use url-encoded values.
    ///         Setting to `true` will use url-encoding for values.
    ///         Setting to `false` will encode only characters that are not valid in a url query (the default behavior of `URLComponents`
    /// - Returns: `URLComponents` with the `queryItems` set with the specified encoding
    package func withQueryItems(_ queryItems: [URLQueryItem], urlEncodedValues: Bool = true) -> URLComponents {
        var copy = self

        if queryItems.isEmpty {
            copy.queryItems = nil
        } else if urlEncodedValues {
            /// From the documentation for `percentEncodedQueryItems`:
            /// The `.percentEncodedQueryItems` property assumes the query item names and values are already correctly percent-encoded, and that the query item
            /// names do not contain the query item delimiter characters '&' and '='. Attempting to set an incorrectly percent-encoded query item or a query
            /// item name with the query item delimiter characters '&' and '=' will cause a `fatalError`.
            copy.percentEncodedQueryItems = queryItems.compactMap { queryItem in
                queryItem.addingAPIPercentEncoding()
            }
        } else {
            copy.queryItems = queryItems
        }

        return copy
    }
}

extension CharacterSet {
    /// Defines a character set for URL Encoding based on `RFC 3986: 3.4 (Query)` but excludes the `+` character.
    /// https://datatracker.ietf.org/doc/html/rfc3986/#section-3.4
    ///
    /// Using this `CharacterSet` to encode a string will cause the `+` character to be encoded as a literal rather than allowing it to remain unencoded, where
    /// it would represent a space character.
    /// ## Allowed Characters in Query (Standard)
    /// - `pchar` _(see below)_
    /// - `/`
    /// - `?`
    ///
    /// ## Allowed Characters in Query (including `+` Literal)
    ///
    /// ### `pchar`
    /// - Unreserved _(see below)_
    /// - Sub-Delims _(see below)_
    /// - `:`
    /// - `@`
    ///
    /// ### Unreserved
    /// - Uppercase and lowercase letters
    /// - Decimal digits
    /// - `- . _ ~`
    ///
    /// ### Sub-Delims
    /// `! $ & ' ( ) * + , ; =`
    package static var urlQueryAllowedWithLiteralPlusSign: CharacterSet {
        .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+"))
    }

    /// Defines a character set for URL Encoding of a query "name" or "value",  based on `RFC 3986: 3.4 (Query)`, and  excludes the `+` character.
    /// https://datatracker.ietf.org/doc/html/rfc3986/#section-3.4
    ///
    /// Using this `CharacterSet` to encode a string will cause any `+`, `&`, and `=` characters in a "name" or "value" (`name=value`) to be encoded.
    /// ## Allowed Characters in Query (Standard)
    /// - `pchar` _(see below)_
    /// - `/`
    /// - `?`
    ///
    /// ## Allowed Characters in Query (including `+` Literal)
    ///
    /// ### `pchar`
    /// - Unreserved _(see below)_
    /// - Sub-Delims _(see below)_
    /// - `:`
    /// - `@`
    ///
    /// ### Unreserved
    /// - Uppercase and lowercase letters
    /// - Decimal digits
    /// - `- . _ ~`
    ///
    /// ### Sub-Delims
    /// `! $ & ' ( ) * + , ; =`
    package static var urlQueryNameValueAllowedWithLiteralPlusSign: CharacterSet {
        .urlQueryAllowedWithLiteralPlusSign.subtracting(CharacterSet(charactersIn: "& ="))
    }
}

extension URLQueryItem {
    /// Returns a `URLQueryItem?` whose value has been percent-encoded for the specified character set.
    ///
    /// A Percent-encoded `URLQueryItem` should only be assigned to `URLComponents.percentEncodedQueryItems`.
    /// It is a mistake to assign an encoded `URLQueryItem` to `URLComponents.queryItems`.
    /// If a percent-encoded `URLQueryItem` is assigned as a `.queryItem`, the encoded value will be double-encoded.
    ///
    /// - Returns: A `URLQueryItem?` configured with the specified encoding, returns `nil` if the `name` cannot be encoded
    fileprivate func addingAPIPercentEncoding() -> URLQueryItem? {
        guard let name = name.addingPercentEncoding(withAllowedCharacters: .urlQueryNameValueAllowedWithLiteralPlusSign) else {
            return nil
        }

        let value = value?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryNameValueAllowedWithLiteralPlusSign)

        return URLQueryItem(name: name, value: value)
    }
}
