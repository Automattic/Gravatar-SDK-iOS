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

    public init?(with profileID: ProfileIdentifier) {
        guard let url = Self.baseURL?.appending(pathComponent: profileID.identifier) else {
            return nil
        }

        self.url = url
        self.hash = profileID.identifier
    }
}

extension String {
    fileprivate static let baseURL = "https://gravatar.com/"
}
