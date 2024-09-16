import Foundation

extension URLComponents {
    package mutating func setQueryItems(_ queryItems: [URLQueryItem], shouldEncodePlusChar: Bool = true) {
        self.queryItems = queryItems

        if shouldEncodePlusChar {
            self.percentEncodedQuery = self.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }
    }
}
