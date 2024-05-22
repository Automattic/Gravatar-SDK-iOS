import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

/** The user&#39;s contact information. This is only available if the user has chosen to make it public. This is only provided in authenticated API requests. */
public struct ProfileContactInfo: Codable, Hashable {
    /** The user's home phone number. */
    public private(set) var homePhone: String?
    /** The user's work phone number. */
    public private(set) var workPhone: String?
    /** The user's cell phone number. */
    public private(set) var cellPhone: String?
    /** The user's email address as provided on the contact section of the profile. Might differ from their account emails. */
    public private(set) var email: String?
    /** The URL to the user's contact form. */
    public private(set) var contactForm: String?
    /** The URL to the user's calendar. */
    public private(set) var calendar: String?

    public init(
        homePhone: String? = nil,
        workPhone: String? = nil,
        cellPhone: String? = nil,
        email: String? = nil,
        contactForm: String? = nil,
        calendar: String? = nil
    ) {
        self.homePhone = homePhone
        self.workPhone = workPhone
        self.cellPhone = cellPhone
        self.email = email
        self.contactForm = contactForm
        self.calendar = calendar
    }

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case homePhone = "home_phone"
        case workPhone = "work_phone"
        case cellPhone = "cell_phone"
        case email
        case contactForm = "contact_form"
        case calendar
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(homePhone, forKey: .homePhone)
        try container.encodeIfPresent(workPhone, forKey: .workPhone)
        try container.encodeIfPresent(cellPhone, forKey: .cellPhone)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(contactForm, forKey: .contactForm)
        try container.encodeIfPresent(calendar, forKey: .calendar)
    }
}
