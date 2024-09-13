import Foundation

extension URLComponents {
    /// Returns a `URLComponents` with the `queryItems` set and optinally encoded.
    ///
    /// - Parameters:
    ///   - queryItems: An array of `URLQueryItem`s
    ///   - urlEncodedValues: Whether to use url-encoded values.
    ///         Setting to `true` will use url-encoding for values.
    ///         Setting to `false` will encode only characters that are not valid in a url query
    /// - Returns: `URLComponents` with the `queryItems` set with the specified encoding
    package func withQueryItems(_ queryItems: [URLQueryItem], urlEncodedValues: Bool = true) -> URLComponents {
        var copy = self

        if queryItems.isEmpty {
            copy.queryItems = nil
        } else if urlEncodedValues {
            copy.percentEncodedQueryItems = queryItems.map { $0.percentEncodedValue(withAllowedCharacters: .restAPI) }
        } else {
            copy.queryItems = queryItems
        }

        return copy
    }
}

extension CharacterSet {
    /// Defines a character set for URL Encoding based on `RFC 3986`
    /// https://datatracker.ietf.org/doc/html/rfc3986/#page-12
    ///
    /// ## Unreserved Characters
    /// - Uppercase and lowercase letters
    /// - Decimal digits
    /// - `- . _ ~`
    ///
    /// ## Reserved Characters
    /// `: / ? # [ ] @ ! $ & ' ( ) * + , ; =`
    fileprivate static var restAPI: CharacterSet {
        .alphanumerics.union(CharacterSet(charactersIn: "-_.~"))
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
    fileprivate func percentEncodedValue(withAllowedCharacters: CharacterSet) -> URLQueryItem {
        var newQueryItem = self
        newQueryItem.value = value?
            .addingPercentEncoding(withAllowedCharacters: withAllowedCharacters)

        return newQueryItem
    }
}
