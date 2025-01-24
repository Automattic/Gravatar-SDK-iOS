import Foundation

extension CharacterSet {
    /// The set of allowed characters in the 'product' of a User-Agent string (RFC-9110 10.1.5)
    /// ```
    /// product         = token ["/" product-version]
    /// product-version = token
    /// token           = 1*tchar
    /// tchar           = "!" / "#" / "$" / "%" / "&" / "'" / "*"
    ///                 / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
    ///                 / DIGIT / ALPHA
    ///                 ; any VCHAR, except delimiters
    /// ```
    static let productIdentifierAllowed: CharacterSet = {
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: "!#$%&'*+-.^_|~`")

        return allowedCharacters
    }()
}
