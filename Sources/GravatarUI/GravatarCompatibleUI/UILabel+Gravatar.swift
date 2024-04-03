import Foundation
import UIKit

extension GravatarWrapper where Component: UILabel {
    public var displayName: DisplayNameField {
        DisplayNameField(label: component)
    }

    public var personalInfo: PersonalInfoField {
        PersonalInfoField(label: component)
    }

    public var aboutMe: AboutMeField {
        AboutMeField(label: component)
    }
}
