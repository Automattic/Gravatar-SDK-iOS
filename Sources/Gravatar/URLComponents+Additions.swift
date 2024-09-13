import Foundation

extension URLComponents {
    /// Returns a `URLComponents` with the `queryItems` set.
    ///
    /// The default behavior is to percent-encode all `+` characters.  This differs from
    /// the default behavior of `URLComponents`.  By default, `URLComponents` doesn't encode
    /// the `+` character because it is a valid character in a query. This can cause problems when
    /// query values contain a literal `+` character, which won't be interpreted as a `+`.
    ///
    /// Note that this does not affect the `.queryItems` of the object.  It only makes changes to the
    /// `.percentEncodedQuery`.
    ///
    /// - Parameters:
    ///   - queryItems: An array of `URLQueryItem`s
    ///   - plusSignLiteralEncoded: Whether to fully percent-encode values.
    ///         Setting to `true` will encode the `+` character.
    ///         Setting to `false` will leave the default encoding in place
    /// - Returns: `URLComponents` with the `queryItems` set with the specified encoding
    package func withQueryItems(_ queryItems: [URLQueryItem], plusSignLiteralEncoded: Bool = true) -> URLComponents {
        var copy = self

        guard queryItems.isEmpty == false else {
            return copy
        }

        copy.queryItems = queryItems

        if plusSignLiteralEncoded {
            copy.percentEncodedQuery = copy.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }

        return copy
    }
}
