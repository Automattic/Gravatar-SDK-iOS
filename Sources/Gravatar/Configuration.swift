import Foundation

public actor Configuration {
    private(set) var apiKey: String?
    static public let shared = Configuration()

    private init() {}

    public func configure(with apiKey: String) {
        self.apiKey = apiKey
    }
}
