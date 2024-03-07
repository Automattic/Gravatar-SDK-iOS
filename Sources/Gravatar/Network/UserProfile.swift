import Foundation

public struct UserProfile {
    public let hash: String
    public let requestHash: String
    public let preferredUsername: String
    public let displayName: String?
    public let name: Name?
    public let pronouns: String?
    public let aboutMe: String?

    public let urls: [LinkURL]
    public let photos: [Photo]
    public let emails: [Email]?
    public let accounts: [Account]?

    let profileUrl: String
    let thumbnailUrl: String
    let lastProfileEdit: String?
}

extension UserProfile {
    public var lastProfileEditDate: Date? {
        guard let lastProfileEdit else {
            return nil
        }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withSpaceBetweenDateAndTime]
        return formatter.date(from: lastProfileEdit)
    }

    public var profileURL: URL? {
        URL(string: profileUrl)
    }

    public var thumbnailURL: URL? {
        URL(string: thumbnailUrl)
    }
}

extension UserProfile {
    public struct Name {
        public let givenName: String?
        public let familyName: String?
        public let formatted: String?
    }

    public struct Email {
        public let value: String
        public let isPrimary: Bool
    }

    public struct Account {
        public let domain: String
        public let display: String
        public let username: String
        public let name: String
        public let shortname: String

        public let url: String
        public let iconUrl: String
        public let isVerified: Bool

        public var accountURL: URL? {
            URL(string: url)
        }

        public var iconURL: URL? {
            URL(string: iconUrl)
        }
    }

    public struct LinkURL {
        public let title: String
        public let linkSlug: String?
        public let value: String

        var url: URL? {
            URL(string: value)
        }
    }

    public struct Photo {
        public let type: String?
        public let value: String

        public var url: URL? {
            URL(string: value)
        }
    }
}
