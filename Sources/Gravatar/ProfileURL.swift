import Foundation

public struct ProfileURL {
    public let url: URL
    public let hash: String
    public var avatarURL: AvatarURL? {
        AvatarURL(hash: hash)
    }

    static let baseURL: URL = {
        guard
            let baseURL = URL(string: .baseURL),
            let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false),
            let url = components.url
        else {
            fatalError("A url created from a correct literal string should never fail")
        }
        return url
    }()

    public init(email: String) {
        let hash = email.sanitized.sha256()
        self.init(hash: hash)
    }

    public init(hash: String) {
        self.url = Self.baseURL.appending(pathComponent: hash)
        self.hash = hash
    }
}

extension URLComponents {
    func sanitizingComponents() -> URLComponents {
        var copy = self
        copy.scheme = .scheme
        copy.query = nil
        return copy
    }
}

extension String {
    fileprivate static let scheme = "https"
    fileprivate static let baseURL = "https://gravatar.com/"
}
