import Foundation

/// The subset of data available for update. Field names match the ones in `Profile`. Only the provided fields will be updated.
///
public struct UpdateProfileRequest: Codable, Hashable, Sendable {
    /// The user's display name. This is the name that is displayed on their profile.
    public private(set) var displayName: String?
    /// The about section on a user's profile.
    public private(set) var description: String?
    /// The phonetic pronunciation of the user's name.
    public private(set) var pronunciation: String?
    /// The pronouns the user uses.
    public private(set) var pronouns: String?
    /// The user's location.
    public private(set) var location: String?
    /// The user's job title.
    public private(set) var jobTitle: String?
    /// The user's current company's name.
    public private(set) var company: String?

    public init(
        displayName: String? = nil,
        description: String? = nil,
        pronunciation: String? = nil,
        pronouns: String? = nil,
        location: String? = nil,
        jobTitle: String? = nil,
        company: String? = nil
    ) {
        self.displayName = displayName
        self.description = description
        self.pronunciation = pronunciation
        self.pronouns = pronouns
        self.location = location
        self.jobTitle = jobTitle
        self.company = company
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case displayName = "display_name"
        case description
        case pronunciation
        case pronouns
        case location
        case jobTitle = "job_title"
        case company
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(pronunciation, forKey: .pronunciation)
        try container.encodeIfPresent(pronouns, forKey: .pronouns)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(jobTitle, forKey: .jobTitle)
        try container.encodeIfPresent(company, forKey: .company)
    }
}
