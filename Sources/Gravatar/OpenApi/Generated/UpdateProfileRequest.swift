import Foundation

/// The subset of data available for update. Field names match the ones in `Profile`. Only the provided fields will be updated.
///
public struct UpdateProfileRequest: Codable, Hashable, Sendable {
    /// The user's first name.
    public private(set) var firstName: String?
    /// The user's last name.
    public private(set) var lastName: String?
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
    /// The user's cell phone number.
    public private(set) var cellPhone: String?
    /// The user's contact email address.
    public private(set) var contactEmail: String?
    /// Whether the user's contact information is hidden on their profile.
    public private(set) var hiddenContactInfo: Bool?

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        displayName: String? = nil,
        description: String? = nil,
        pronunciation: String? = nil,
        pronouns: String? = nil,
        location: String? = nil,
        jobTitle: String? = nil,
        company: String? = nil,
        cellPhone: String? = nil,
        contactEmail: String? = nil,
        hiddenContactInfo: Bool? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
        self.description = description
        self.pronunciation = pronunciation
        self.pronouns = pronouns
        self.location = location
        self.jobTitle = jobTitle
        self.company = company
        self.cellPhone = cellPhone
        self.contactEmail = contactEmail
        self.hiddenContactInfo = hiddenContactInfo
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case firstName = "first_name"
        case lastName = "last_name"
        case displayName = "display_name"
        case description
        case pronunciation
        case pronouns
        case location
        case jobTitle = "job_title"
        case company
        case cellPhone = "cell_phone"
        case contactEmail = "contact_email"
        case hiddenContactInfo = "hidden_contact_info"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(pronunciation, forKey: .pronunciation)
        try container.encodeIfPresent(pronouns, forKey: .pronouns)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(jobTitle, forKey: .jobTitle)
        try container.encodeIfPresent(company, forKey: .company)
        try container.encodeIfPresent(cellPhone, forKey: .cellPhone)
        try container.encodeIfPresent(contactEmail, forKey: .contactEmail)
        try container.encodeIfPresent(hiddenContactInfo, forKey: .hiddenContactInfo)
    }
}
