import Foundation

public struct ProfileURL {
    public let url: URL
    public let hash: String
    public var avatarURL: AvatarURL? {
        AvatarURL(hash: hash)
    }

    public init(email: String) {
        self.init(hash: email.sanitized.sha256())
    }

    public init(hash: String) {
        guard
            let baseUrl = URL(string: .baseURL),
            let components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)?.sanitizedComponents(),
            let sanizitedUrl = components.url
        else {
            fatalError("A url created from a correct literal string should never fail")
        }

        self.url = sanizitedUrl.appending(pathComponent: hash)
        self.hash = hash
    }
}

extension URLComponents {
    func sanitizedComponents() -> URLComponents {
        var copy = self
        copy.scheme = .scheme
        copy.query = nil
        return copy
    }
}

private extension String {
    static let scheme = "https"
    static let baseURL = "https://gravatar.com/"
}

extension URL {
    @available(swift, deprecated: 16.0, message: "Use URL.appending(path:) instead")
    func appending(pathComponent path: String) -> URL {
        if #available(iOS 16.0, *) {
            return self.appending(path: path)
        } else {
            return self.appendingPathComponent(path)
        }
    }
}
