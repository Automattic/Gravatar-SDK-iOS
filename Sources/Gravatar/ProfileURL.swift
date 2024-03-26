import Foundation

public struct ProfileURL {
    public let url: URL
    public let hash: String
    public var avatarURL: AvatarURL? {
        AvatarURL(with: .hashID(self.hash))
    }

    static let baseURL: URL? = {
        guard
            let baseURL = URL(string: .baseURL),
            let components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            return nil
        }
        return components.url
    }()

    public init?(email: String) {
        let hash = email.hashed()
        self.init(hash: hash)
    }

    public init?(hash: String) {
        guard let url = Self.baseURL?.appending(pathComponent: hash) else {
            return nil
        }
        self.url = url
        self.hash = hash
    }
}

extension String {
    fileprivate static let baseURL = "https://gravatar.com/"
}
