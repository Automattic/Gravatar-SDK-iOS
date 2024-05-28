import Foundation

public actor Configuration {
    private(set) var apiKey: String?
    public static let shared = Configuration()

    private init() {}

    public func configure(with apiKey: String) {
        self.apiKey = apiKey
    }
}
