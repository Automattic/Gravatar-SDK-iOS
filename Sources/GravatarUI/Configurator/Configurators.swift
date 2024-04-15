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

@MainActor
public struct ButtonConfigurator {
    let button: UIButton

    init(button: UIButton) {
        self.button = button
    }

    public func asProfileButton() -> ProfileButtonBuilder {
        ProfileButtonBuilder(button: button)
    }

    public func asAccountButton() -> AccountButtonBuilder {
        AccountButtonBuilder(button: button)
    }
}

/// Returns the LabelConfigurator created with the given UILabel
public func Configure(_ label: UILabel) -> LabelConfigurator {
    LabelConfigurator(label: label)
}

@MainActor
public func Configure(_ button: UIButton) -> ButtonConfigurator {
    ButtonConfigurator(button: button)
}
