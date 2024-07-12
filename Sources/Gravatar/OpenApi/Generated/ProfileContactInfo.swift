import Foundation

/// The user's contact information. This is only available if the user has chosen to make it public. This is only provided in authenticated API requests.
///
public struct ProfileContactInfo: Codable, Hashable, Sendable {
    /// The user's home phone number.
    public let homePhone: String?
    /// The user's work phone number.
    public let workPhone: String?
    /// The user's cell phone number.
    public let cellPhone: String?
    /// The user's email address as provided on the contact section of the profile. Might differ from their account emails.
    public let email: String?
    /// The URL to the user's contact form.
    public let contactForm: String?
    /// The URL to the user's calendar.
    public let calendar: String?

    @available(*, deprecated, message: "init will become internal on the next release")
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

    @available(*, deprecated, message: "CodingKeys will become internal on the next release.")
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case homePhone = "home_phone"
        case workPhone = "work_phone"
        case cellPhone = "cell_phone"
        case email
        case contactForm = "contact_form"
        case calendar
    }

    enum InternalCodingKeys: String, CodingKey, CaseIterable {
        case homePhone = "home_phone"
        case workPhone = "work_phone"
        case cellPhone = "cell_phone"
        case email
        case contactForm = "contact_form"
        case calendar
    }

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: InternalCodingKeys.self)
        try container.encodeIfPresent(homePhone, forKey: .homePhone)
        try container.encodeIfPresent(workPhone, forKey: .workPhone)
        try container.encodeIfPresent(cellPhone, forKey: .cellPhone)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(contactForm, forKey: .contactForm)
        try container.encodeIfPresent(calendar, forKey: .calendar)
    }
}
