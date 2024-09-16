import Foundation

extension URLComponents {
    /// Returns a `URLComponents` object with its `.queryItems` property set
    /// - Parameters:
    ///   - queryItems: an array of `URLQueryItem`.  If empty, the `.queryItems` property will be set to `nil`
    ///   - shouldEncodePlusChar: whether to encode `+` characters.  The default matches the default behavior of `URLComponents`,
    ///   which does not encode `+` characters.
    /// - Returns: a `URLComponents` object with its `.queryItems` property set
    package func settingQueryItems(_ queryItems: [URLQueryItem], shouldEncodePlusChar: Bool = false) -> URLComponents {
        var copy = self

        guard !queryItems.isEmpty else {
            copy.queryItems = nil
            return copy
        }

        copy.queryItems = queryItems

        if shouldEncodePlusChar {
            copy.percentEncodedQuery = copy.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }

        return copy
    }
}
