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

    /// Replaces the query item if it exists, otherwise adds a new one.
    package func replacingQueryItem(name: String, value: String?) -> URLComponents {
        var copy = self
        let newItem = URLQueryItem(name: name, value: value)

        if var queryItems = self.queryItems,
           let sizeItemIndex = queryItems.firstIndex(where: { $0.name == name })
        {
            // Replace the query item
            queryItems[sizeItemIndex] = newItem
            copy.queryItems = queryItems
        } else {
            // Add the query item if it doesn't exist
            copy.queryItems = (self.queryItems ?? []) + [newItem]
        }

        return copy
    }
}
