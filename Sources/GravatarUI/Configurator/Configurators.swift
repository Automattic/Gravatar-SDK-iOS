import UIKit

@MainActor
/// Provides several UILabel builders.
///
/// You shouldn't need to use this Configurator unless you create a profile view from scratch.
/// If you need your own profile view design, is recommended to subclass ``BaseProfileView`` instead.
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
/// A ButtonConfigurator helps configuring the button style to be used as part of the a profile view.
///
/// You shouldn't need to use this Configurator unless you create a profile view from scratch.
/// If you need your own profile view design, is recommended to subclass ``BaseProfileView`` instead.
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

@MainActor
/// Returns a LabelConfigurator instance created with the given UILabel
public func Configure(_ label: UILabel) -> LabelConfigurator {
    LabelConfigurator(label: label)
}

@MainActor
/// Returns a ButtonConfigurator instance created with the given UIButton
public func Configure(_ button: UIButton) -> ButtonConfigurator {
    ButtonConfigurator(button: button)
}
