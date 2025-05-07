import Foundation

/// Represents a set of fields that can be shown in the "About" section of the QuickEditor.
public struct AboutInfoField: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }

    /// The user’s display name.
    public static let displayName = AboutInfoField(rawValue: 1 << 0)
    /// A short biography or description about the user.
    public static let aboutMe = AboutInfoField(rawValue: 1 << 1)
    /// A phonetic pronunciation of the user’s name.
    public static let pronunciation = AboutInfoField(rawValue: 1 << 2)
    /// The pronouns the user identifies with (e.g., she/her, they/them).
    public static let pronouns = AboutInfoField(rawValue: 1 << 3)
    /// The user's geographic location.
    public static let location = AboutInfoField(rawValue: 1 << 4)
    /// The user's current job title or role.
    public static let jobTitle = AboutInfoField(rawValue: 1 << 5)
    /// The company or organization the user is affiliated with.
    public static let company = AboutInfoField(rawValue: 1 << 6)

    /// A convenience set representing all possible about info fields.
    public static let all: AboutInfoField = [
        .displayName,
        .aboutMe,
        .pronunciation,
        .pronouns,
        .location,
        .jobTitle,
        .company,
    ]

    /// A subset of fields that are personal.
    public static let personalFields: AboutInfoField = [
        .displayName,
        .aboutMe,
        .pronunciation,
        .pronouns,
        .location,
    ]

    /// A subset of fields that are professional or work-related.
    public static let professionalFields: AboutInfoField = [
        .jobTitle,
        .company,
    ]

    var hasMultipleCategories: Bool {
        [
            !self.intersection(.personalFields).isEmpty,
            !self.intersection(.professionalFields).isEmpty,
        ].hasMoreThanOneTrue
    }

    func localizedName() -> String {
        switch self {
        case .displayName:
            SDKLocalizedString(
                "Profile.AboutInfoField.displayName",
                value: "Display Name",
                comment: "Label of a field that contains a user’s display name."
            )
        case .aboutMe:
            SDKLocalizedString(
                "Profile.AboutInfoField.aboutMe",
                value: "About Me",
                comment: "Label of a field that contains a short biography or description about the user."
            )
        case .pronunciation:
            SDKLocalizedString(
                "Profile.AboutInfoField.pronunciation",
                value: "Pronunciation",
                comment: "Label of a field that contains a phonetic pronunciation of the user’s name."
            )
        case .pronouns:
            SDKLocalizedString(
                "Profile.AboutInfoField.pronouns",
                value: "Pronouns",
                comment: "Label of a field that contains the pronouns the user identifies with (e.g., she/her, they/them)."
            )
        case .location:
            SDKLocalizedString(
                "Profile.AboutInfoField.location",
                value: "Location",
                comment: "Label of a field that contains the user's geographic location."
            )
        case .jobTitle:
            SDKLocalizedString(
                "Profile.AboutInfoField.jobTitle",
                value: "Job Title",
                comment: "Label of a field that contains the user's current job title or role."
            )
        case .company:
            SDKLocalizedString(
                "Profile.AboutInfoField.company",
                value: "Company",
                comment: "Label of a field that contains the company or organization the user is affiliated with."
            )
        default:
            ""
        }
    }
}
