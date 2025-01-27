import Foundation

struct UserAgent {
    struct Product: CustomStringConvertible {
        let productIdentifier: String?
        let version: String?

        var description: String {
            var encodedProduct = productIdentifier?.addingPercentEncoding(withAllowedCharacters: .productIdentifierAllowed) ?? "Unknown"

            if let encodedVersion = version?.addingPercentEncoding(withAllowedCharacters: .productIdentifierAllowed) {
                encodedProduct += "/\(encodedVersion)"
            }
            return encodedProduct
        }

        init(productIdentifier: String?, version: String? = nil) {
            self.productIdentifier = productIdentifier
            self.version = version
        }
    }

    private let product: Product
    private let subProducts: [Product]

    /// An object that represents the elements of a `User-Agent` header in an HTTP request.
    /// - Parameters:
    ///   - product: Main product to be specified in the User-Agent header
    ///   - subProducts: Additional products to be specified in the User-Agent
    init(product: Product, subProducts: [Product] = []) {
        self.product = product
        self.subProducts = subProducts
    }

    /// The encoded value for a `User-Agent` header
    var encodedHeaderValue: String {
        let allProducts: [Product] = [product] + subProducts
        return allProducts.map { String(describing: $0) }.joined(separator: " ")
    }
}

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
