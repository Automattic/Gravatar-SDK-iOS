import Foundation

// NOTE: Incomplete Profile wraper.
// From what I found, there's no way yet to make the generator create camelCase fields.
// Mapping `Components.Schemas.Profile` to our UserProfile is a must.
// (`PublicProfile` is just an example to keep UserProfile as it is for now.)
public struct PublicProfile: Decodable {
    let profile: Components.Schemas.Profile

    public var hash: String {
        profile.hash
    }

    public var displayName: String? {
        profile.display_name
    }

    public var profileURLString: String {
        profile.profile_url
    }

    public var profileURL: URL? {
        URL(string: profileURLString)
    }

    public var avatarURLString: String {
        profile.avatar_url
    }

    public var avatarURL: URL? {
        URL(string: profile.avatar_url)
    }

    public var avatarAltText: String {
        profile.avatar_alt_text
    }

    public var location: String {
        profile.location
    }

    public var description: String {
        profile.description
    }

    public var jobTitle: String {
        profile.job_title
    }

    public var company: String {
        profile.company
    }
}
