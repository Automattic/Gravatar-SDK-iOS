import Foundation
import Testing

@testable import Gravatar

struct CharacterSetTests {
    @Test("Product Identifier Allowed", arguments: [
        "ExampleBrowser",
        "ExampleBrowser!#$%&'*+-.^_|~`",
        "Example-Browser_1.2+3.4~5",
    ])
    func productIdentifierAllowed(validIdentifier: String) {
        #expect(
            validIdentifier.unicodeScalars.allSatisfy { CharacterSet.productIdentifierAllowed.contains($0) }
        )
    }

    @Test("Product Identifier Not Allowed", arguments: [
        "Example(Browser)", // Delimiters not allowed
        "Example@Browser", // Delimiters not allowed
        "Example Browser" // Space not allowed
    ])
    func productIdentifierNotAllowed(invalidIdentifiers: String) {
        #expect(
            invalidIdentifiers.unicodeScalars.allSatisfy { CharacterSet.productIdentifierAllowed.contains($0) } == false
        )
    }

    @Test("Version Identifier Allowed", arguments: [
        "4",
        "2025.01.24",
        "1.21-gigawatts",
        "1.0.0-beta.2+exp.sha.5114f85",
        "v1.2.3",
        "4_Keyword!#$%&'*+-.^_|~`"
    ])
    func versionIdentifierAllowed(validIdentifier: String) {
        #expect(
            validIdentifier.unicodeScalars.allSatisfy { CharacterSet.productIdentifierAllowed.contains($0) }
        )
    }

    @Test("Version Identifier Not Allowed", arguments: [
        "1.0(1234)", // Delimiters not allowed
        "1.0@Keyword", // Delimiters not allowed
        "1.0 Keyword", // Space not allowed
        "1.0.🔥", // Emoji not allowed
        "∞.42", // Non-ascii characters not allowed
    ])
    func versionIdentifierNotAllowed(invalidIdentifiers: String) {
        #expect(
            invalidIdentifiers.unicodeScalars.allSatisfy { CharacterSet.productIdentifierAllowed.contains($0) } == false
        )
    }
}
