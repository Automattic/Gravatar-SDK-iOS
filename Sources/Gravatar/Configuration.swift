import Foundation

@MainActor
public class Configuration {
    private(set) var apiKey: String?
    static let shared = Configuration(apiKey: nil)

    private init(apiKey: String? = nil) {
        self.apiKey = apiKey
    }

    public static func configure(with apiKey: String) {
        shared.apiKey = apiKey
    }
}
