import Foundation

struct FetchProfileResponse: Decodable {
    let entry: [UserProfile]
}

public struct UserProfile {
    public let hash: String
    public let requestHash: String
    public let preferredUsername: String
    public let displayName: String
    public let name: Name?
    public let pronouns: String?
    public let aboutMe: String?

    public let urls: [LinkURL]
    public let photos: [Photo]
    public let emails: [Email]?
    public let accounts: [Account]?

    let profileUrl: String
    let thumbnailUrl: String
    let last_profile_edit: String?
}

extension UserProfile {
    public var lastProfileEdit: Date? {
        guard let lastEditedDate = last_profile_edit else {
            return nil
        }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withSpaceBetweenDateAndTime]
        return formatter.date(from: lastEditedDate)
    }

    public var profileURL: URL? {
        URL(string: profileUrl)
    }

    public var thumbnailURL: URL? {
        URL(string: thumbnailUrl)
    }
}

extension UserProfile: Decodable {}

extension UserProfile {
    public struct Name: Decodable {
        public let givenName: String
        public let familyName: String
        public let formatted: String
    }

    public struct Email: Decodable {
        public let value: String
        let primary: String
        public var isPrimary: Bool {
            primary == "true"
        }
    }

    public struct Account: Decodable {
        public let domain: String
        public let display: String
        public let username: String
        public let name: String
        public let shortname: String

        let url: String
        let iconUrl: String
        let verified: String

        public var accountURL: URL? {
            URL(string: url)
        }

        public var iconURL: URL? {
            URL(string: iconUrl)
        }
        
        public var isVerified: Bool {
            verified == "true"
        }
    }

    public struct LinkURL: Decodable {
        public let title: String
        let value: String
        let link_slug: String?

        var url: URL? {
            URL(string: value)
        }

        var linkSlug: String? {
            link_slug
        }
    }

    public struct Photo: Decodable {
        public let type: String
        let value: String

        public var url: URL? {
            URL(string: value)
        }
    }
}
