import Foundation

struct Root: Decodable {
    let entry: [UserProfile]
}

public struct UserProfile: Decodable {
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

    private let profileUrl: String
    public var profileURLString: String {
        profileUrl
    }

    public var profileURL: URL? {
        URL(string: profileURLString)
    }

    private let thumbnailUrl: String
    public var thumbnailURLString: String {
        thumbnailUrl
    }

    public var thumbnailURL: URL? {
        URL(string: thumbnailURLString)
    }

    let lastProfileEdit: String?
}

extension UserProfile {
    public var lastProfileEditDate: Date? {
        guard let lastProfileEdit else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: lastProfileEdit)
    }
}

extension UserProfile {
    public struct Name: Decodable {
        public let givenName: String?
        public let familyName: String?
        public let formatted: String?
    }

    public struct Email: Decodable {
        public let value: String
        public let isPrimary: Bool

        enum CodingKeys: String, CodingKey {
            case value
            case isPrimary = "primary"
        }

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<UserProfile.Email.CodingKeys> = try decoder.container(keyedBy: UserProfile.Email.CodingKeys.self)

            self.value = try container.decode(String.self, forKey: CodingKeys.value)

            if let primaryString = try? container.decodeIfPresent(String.self, forKey: CodingKeys.isPrimary) {
                self.isPrimary = primaryString == "true"
            } else if let primaryBool = try? container.decodeIfPresent(Bool.self, forKey: CodingKeys.isPrimary) {
                self.isPrimary = primaryBool
            } else {
                self.isPrimary = false
            }
        }
    }

    public struct Account: Decodable {
        public let domain: String
        public let display: String
        public let username: String
        public let name: String
        public let shortname: String

        public let url: String
        public let iconURLString: String
        public let isVerified: Bool

        public var accountURL: URL? {
            URL(string: url)
        }

        public var iconURL: URL? {
            URL(string: iconURLString)
        }

        enum CodingKeys: String, CodingKey {
            case domain
            case display
            case username
            case name
            case shortname
            case url
            case iconUrl
            case isVerified = "verified"
        }

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<UserProfile.Account.CodingKeys> = try decoder.container(keyedBy: UserProfile.Account.CodingKeys.self)
            self.domain = try container.decode(String.self, forKey: UserProfile.Account.CodingKeys.domain)
            self.display = try container.decode(String.self, forKey: UserProfile.Account.CodingKeys.display)
            self.username = try container.decode(String.self, forKey: UserProfile.Account.CodingKeys.username)
            self.name = try container.decode(String.self, forKey: UserProfile.Account.CodingKeys.name)
            self.shortname = try container.decode(String.self, forKey: UserProfile.Account.CodingKeys.shortname)
            self.url = try container.decode(String.self, forKey: UserProfile.Account.CodingKeys.url)
            self.iconURLString = try container.decode(String.self, forKey: UserProfile.Account.CodingKeys.iconUrl)

            if let verifiedString = try? container.decodeIfPresent(String.self, forKey: CodingKeys.isVerified) {
                self.isVerified = verifiedString == "true"
            } else if let verifiedBool = try? container.decodeIfPresent(Bool.self, forKey: CodingKeys.isVerified) {
                self.isVerified = verifiedBool
            } else {
                self.isVerified = false
            }
        }
    }

    public struct LinkURL: Decodable {
        public let title: String
        public let linkSlug: String?
        public let value: String

        var url: URL? {
            URL(string: value)
        }
    }

    public struct Photo: Decodable {
        public let type: String?
        public let value: String

        public var url: URL? {
            URL(string: value)
        }
    }
}
