import Foundation

struct UserProfileMapper {
    private struct Root: Decodable {
        let entry: [Profile]

        var profile: [UserProfile] {
            entry.map(\.profile)
        }
    }

    private struct Profile: Decodable {
        let hash: String
        let requestHash: String
        let preferredUsername: String
        let displayName: String
        let name: Name?
        let pronouns: String?
        let aboutMe: String?

        let urls: [LinkURL]
        let photos: [Photo]
        let emails: [Email]?
        let accounts: [Account]?

        let profileUrl: String
        let thumbnailUrl: String
        let lastProfileEdit: String?

        var profile: UserProfile {
            UserProfile(
                hash: self.hash,
                requestHash: self.requestHash,
                preferredUsername: self.preferredUsername,
                displayName: self.displayName,
                name: self.name?.name,
                pronouns: self.pronouns,
                aboutMe: self.aboutMe,
                urls: self.urls.map(\.linkUrl),
                photos: self.photos.map(\.photo),
                emails: self.emails?.map(\.email),
                accounts: self.accounts?.map(\.account),
                profileUrl: self.profileUrl,
                thumbnailUrl: self.thumbnailUrl,
                lastProfileEdit: self.lastProfileEdit
            )
        }

        struct Name: Decodable {
            let givenName: String
            let familyName: String
            let formatted: String

            var name: UserProfile.Name {
                UserProfile.Name(
                    givenName: givenName,
                    familyName: familyName,
                    formatted: formatted
                )
            }
        }

        struct Email: Decodable {
            let value: String
            let primary: Bool

            var email: UserProfile.Email {
                UserProfile.Email(
                    value: value,
                    isPrimary: primary
                )
            }

            enum CodingKeys: CodingKey {
                case value
                case primary
            }

            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<Profile.Email.CodingKeys> = try decoder.container(keyedBy: Profile.Email.CodingKeys.self)

                if let primaryString = try? container.decodeIfPresent(String.self, forKey: Profile.Email.CodingKeys.primary) {
                    self.primary = primaryString == "true"
                } else if let primaryBool = try? container.decodeIfPresent(Bool.self, forKey: Profile.Email.CodingKeys.primary) {
                    self.primary = primaryBool
                } else {
                    self.primary = false
                }

                self.value = try container.decode(String.self, forKey: Profile.Email.CodingKeys.value)
            }
        }

        struct Account: Decodable {
            let domain: String
            let display: String
            let username: String
            let name: String
            let shortname: String

            let url: String
            let iconUrl: String
            let verified: Bool

            var account: UserProfile.Account {
                UserProfile.Account(
                    domain: domain,
                    display: display,
                    username: username,
                    name: name,
                    shortname: shortname,
                    url: url,
                    iconUrl: iconUrl,
                    isVerified: verified
                )
            }

            enum CodingKeys: CodingKey {
                case domain
                case display
                case username
                case name
                case shortname
                case url
                case iconUrl
                case verified
            }

            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<UserProfileMapper.Profile.Account.CodingKeys> = try decoder
                    .container(keyedBy: UserProfileMapper.Profile.Account.CodingKeys.self)
                self.domain = try container.decode(String.self, forKey: UserProfileMapper.Profile.Account.CodingKeys.domain)
                self.display = try container.decode(String.self, forKey: UserProfileMapper.Profile.Account.CodingKeys.display)
                self.username = try container.decode(String.self, forKey: UserProfileMapper.Profile.Account.CodingKeys.username)
                self.name = try container.decode(String.self, forKey: UserProfileMapper.Profile.Account.CodingKeys.name)
                self.shortname = try container.decode(String.self, forKey: UserProfileMapper.Profile.Account.CodingKeys.shortname)
                self.url = try container.decode(String.self, forKey: UserProfileMapper.Profile.Account.CodingKeys.url)
                self.iconUrl = try container.decode(String.self, forKey: UserProfileMapper.Profile.Account.CodingKeys.iconUrl)

                if let verifiedString = try? container.decodeIfPresent(String.self, forKey: Profile.Account.CodingKeys.verified) {
                    self.verified = verifiedString == "true"
                } else if let verifiedBool = try? container.decodeIfPresent(Bool.self, forKey: Profile.Account.CodingKeys.verified) {
                    self.verified = verifiedBool
                } else {
                    self.verified = false
                }
            }
        }

        struct LinkURL: Decodable {
            let title: String
            let linkSlug: String?
            let value: String

            var linkUrl: UserProfile.LinkURL {
                UserProfile.LinkURL(
                    title: self.title,
                    linkSlug: self.linkSlug,
                    value: self.value
                )
            }
        }

        struct Photo: Decodable {
            let type: String
            let value: String

            var photo: UserProfile.Photo {
                UserProfile.Photo(
                    type: type,
                    value: value
                )
            }
        }
    }

    static func map(_ data: Data, _: HTTPURLResponse) -> Result<UserProfile, ProfileServiceError> {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let root = try decoder.decode(Root.self, from: data)
            let profile = try profile(from: root.profile)
            return .success(profile)
        } catch let error as HTTPClientError {
            return .failure(.responseError(reason: error.map()))
        } catch _ as ProfileService.CannotCreateURLFromGivenPath {
            return .failure(.requestError(reason: .urlInitializationFailed))
        } catch let error as ProfileServiceError {
            return .failure(error)
        } catch _ as DecodingError {
            return .failure(.noProfileInResponse)
        } catch {
            return .failure(.responseError(reason: .unexpected(error)))
        }
    }

    private static func profile(from profiles: [UserProfile]) throws -> UserProfile {
        guard let profile = profiles.first else {
            throw ProfileServiceError.noProfileInResponse
        }

        return profile
    }
}
