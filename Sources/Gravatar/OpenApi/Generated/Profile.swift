import Foundation

/// A user's profile information.
///
public struct Profile: Codable, Hashable, Sendable {
    /// The SHA256 hash of the user's primary email address.
    public private(set) var hash: String
    /// The user's display name. This is the name that is displayed on their profile.
    public private(set) var displayName: String
    /// The full URL for the user's profile.
    public private(set) var profileUrl: String
    /// The URL for the user's avatar image if it has been set.
    public private(set) var avatarUrl: String
    /// The alt text for the user's avatar image if it has been set.
    public private(set) var avatarAltText: String
    /// The user's location.
    public private(set) var location: String
    /// The about section on a user's profile.
    public private(set) var description: String
    /// The user's job title.
    public private(set) var jobTitle: String
    /// The user's current company's name.
    public private(set) var company: String
    /// A list of verified accounts the user has added to their profile. This is limited to a max of 4 in unauthenticated requests.
    public private(set) var verifiedAccounts: [VerifiedAccount]
    /// The phonetic pronunciation of the user's name.
    public private(set) var pronunciation: String
    /// The pronouns the user uses.
    public private(set) var pronouns: String
    /// A list of links the user has added to their profile. This is only provided in authenticated API requests.
    public private(set) var links: [Link]?
    public private(set) var payments: ProfilePayments?
    public private(set) var contactInfo: ProfileContactInfo?
    /// Additional images a user has uploaded. This is only provided in authenticated API requests.
    public private(set) var gallery: [GalleryImage]?
    /// The number of verified accounts the user has added to their profile. This count includes verified accounts the user is hiding from their profile. This
    /// is only provided in authenticated API requests.
    public private(set) var numberVerifiedAccounts: Int?
    /// The date and time (UTC) the user last edited their profile. This is only provided in authenticated API requests.
    public private(set) var lastProfileEdit: Date?
    /// The date the user registered their account. This is only provided in authenticated API requests.
    public private(set) var registrationDate: Date?

    public init(
        hash: String,
        displayName: String,
        profileUrl: String,
        avatarUrl: String,
        avatarAltText: String,
        location: String,
        description: String,
        jobTitle: String,
        company: String,
        verifiedAccounts: [VerifiedAccount],
        pronunciation: String,
        pronouns: String,
        links: [Link]? = nil,
        payments: ProfilePayments? = nil,
        contactInfo: ProfileContactInfo? = nil,
        gallery: [GalleryImage]? = nil,
        numberVerifiedAccounts: Int? = nil,
        lastProfileEdit: Date? = nil,
        registrationDate: Date? = nil
    ) {
        self.hash = hash
        self.displayName = displayName
        self.profileUrl = profileUrl
        self.avatarUrl = avatarUrl
        self.avatarAltText = avatarAltText
        self.location = location
        self.description = description
        self.jobTitle = jobTitle
        self.company = company
        self.verifiedAccounts = verifiedAccounts
        self.pronunciation = pronunciation
        self.pronouns = pronouns
        self.links = links
        self.payments = payments
        self.contactInfo = contactInfo
        self.gallery = gallery
        self.numberVerifiedAccounts = numberVerifiedAccounts
        self.lastProfileEdit = lastProfileEdit
        self.registrationDate = registrationDate
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case hash
        case displayName = "display_name"
        case profileUrl = "profile_url"
        case avatarUrl = "avatar_url"
        case avatarAltText = "avatar_alt_text"
        case location
        case description
        case jobTitle = "job_title"
        case company
        case verifiedAccounts = "verified_accounts"
        case pronunciation
        case pronouns
        case links
        case payments
        case contactInfo = "contact_info"
        case gallery
        case numberVerifiedAccounts = "number_verified_accounts"
        case lastProfileEdit = "last_profile_edit"
        case registrationDate = "registration_date"
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hash, forKey: .hash)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(profileUrl, forKey: .profileUrl)
        try container.encode(avatarUrl, forKey: .avatarUrl)
        try container.encode(avatarAltText, forKey: .avatarAltText)
        try container.encode(location, forKey: .location)
        try container.encode(description, forKey: .description)
        try container.encode(jobTitle, forKey: .jobTitle)
        try container.encode(company, forKey: .company)
        try container.encode(verifiedAccounts, forKey: .verifiedAccounts)
        try container.encode(pronunciation, forKey: .pronunciation)
        try container.encode(pronouns, forKey: .pronouns)
        try container.encodeIfPresent(links, forKey: .links)
        try container.encodeIfPresent(payments, forKey: .payments)
        try container.encodeIfPresent(contactInfo, forKey: .contactInfo)
        try container.encodeIfPresent(gallery, forKey: .gallery)
        try container.encodeIfPresent(numberVerifiedAccounts, forKey: .numberVerifiedAccounts)
        try container.encodeIfPresent(lastProfileEdit, forKey: .lastProfileEdit)
        try container.encodeIfPresent(registrationDate, forKey: .registrationDate)
    }
}
