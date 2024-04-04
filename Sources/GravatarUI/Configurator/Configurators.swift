import UIKit

/// Provides several UILabel builders.
public struct LabelConfigurator {
    let label: UILabel

    init(label: UILabel) {
        self.label = label
    }

    public func asDisplayName() -> DisplayNameBuilder {
        DisplayNameBuilder(label: label)
    }

    public func asAboutMe() -> AboutMeBuilder {
        AboutMeBuilder(label: label)
    }

    public func asPersonalInfo() -> PersonalInfoBuilder {
        PersonalInfoBuilder(label: label)
    }
}

/// Returns the LabelConfigurator created with the given UILabel
public func Configure(_ label: UILabel) -> LabelConfigurator {
    LabelConfigurator(label: label)
}
