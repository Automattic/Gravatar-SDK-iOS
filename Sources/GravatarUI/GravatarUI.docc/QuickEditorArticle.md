# Quick Editor

This customizable sheet allows users to update their avatars. Available for both UIKit and SwiftUI.

## Quick Editor Preview

The Quick Editor offers different scopes that allow users to edit various sections of their Gravatar profile.

See ``QuickEditorScopeOption`` for more info.

#### Avatar Picker scope

Layout 1 | Layout 2 | Layout 3 |
----- | ------ | ----- |
![](vertical-large.png) | ![](vertical-medium-expandable.png) | ![](horizontal-intrinsic-height.png) |
Full height sheet | Expandable sheet | Intrinsic height sheet, horizontal scroll |

#### About editor scope

Layout 1 | Layout 2 | Layout 3 |
----- | ------ | ----- |
![](about-editor.png) | ![](about-editor-medium.png) | ![](about-editor-intrinsic.png) |
Full height sheet | Expandable sheet | Intrinsic height sheet |

#### Avatar picker & About editor scope

This scope combines the Avatar picker and the About editor, allowing to switch between them directly in the Quick Editor UI.

![](avatar-and-about.gif)

## Quick Editor - SwiftUI

SDK offers a modifier function to display the QuickEditor sheet. QuickEditor starts the OAuth flow internally to capture an access token. Please refer to <doc:GravatarOAuth> about how to configure the SDK about this.

```swift
import GravatarUI

// [...]

@State private var isPresenting: Bool = false

// [...]

var body: some View {
    VStack(alignment: .leading, spacing: 5) {
        Button("Tap to open the Avatar Picker") {
            isPresentingPicker = true
        }
        .gravatarQuickEditorSheet(
            isPresented: $isPresenting,
            email: "email@domain.com",
            scopeOption: .avatarPicker(.horizontalInstrinsicHeight),
            updateHandler: { updateType in
                switch updateType {
                case is QuickEditorUpdate.Avatar:
                    // Selected avatar has changed
                case let update as QuickEditorUpdate.AboutInfo:
                    // About profile info has been updated
                    // `update.profile` contains the updated profile
                default: break
                }
            },
            onDismiss: {
                // sheet was dismissed
            }
        )
        .preferredColorScheme(.light) // Sets a preferred color scheme; omit to use the system default.
    }
}

// [...]

```

If your app already depends on Gravatar OAuth then you might already have a Gravatar OAuth access token. In this case you can pass it to the QuickEditor directly. This way the QuickEditor won't try to go through the OAuth flow again.

```swift
import GravatarUI

// [...]

@State private var isPresenting: Bool = false
@State private var authToken: String

// [...]

var body: some View {
    VStack(alignment: .leading, spacing: 5) {
        Button("Tap to open the Avatar Picker") {
            isPresentingPicker = true
        }
        .gravatarQuickEditorSheet(
            isPresented: $isPresenting,
            email: "email@domain.com",
            authToken: authToken, // Passes the authentication token
            scopeOption: .avatarPicker(.horizontalInstrinsicHeight),
            updateHandler: { updateType in
                switch updateType {
                case is QuickEditorUpdate.Avatar:
                    // Selected avatar has changed
                case let update as QuickEditorUpdate.AboutInfo:
                    // About profile info has been updated
                    // `update.profile` contains the updated profile 
                default: break
                }
            },
            onDismiss: {
                // sheet was dismissed
            }
        )
        .preferredColorScheme(.light) // Sets a preferred color scheme; omit to use the system default.
    }
}
```

Refer to ``AvatarPickerContentLayout`` to see all the content layout options.

## Quick Editor - UIKit

Similarly, ``QuickEditorPresenter`` can be used to display the QuickEditor in UIKit.

```swift
import GravatarUI

// [...]

// Example with About editor scope
let presenter = QuickEditorPresenter(
    email: Email("email@domain.com"),
    scopeOption: .aboutEditor(),
    configuration: .init(
        interfaceStyle: colorScheme
    )
)
presenter.present(
    in: self,
    onUpdate: { [weak self] updateType in
        switch updateType {
        case is QuickEditorUpdate.Avatar:
            // Selected avatar has changed
        case let update as QuickEditorUpdate.AboutInfo:
            // About profile info has been updated
        default:
            break
        }
    },
    onDismiss: { [weak self] in
        // sheet was dismissed
    }
)
```

### Delete the OAuth token

SDK stores the OAuth token securely in the Keychain. You can call the below method to remove it from the Keychain. It would be convenient to do so when a user logs out from the app.

```swift
import GravatarUI

// [...]

OAuthSession.deleteSession(with: Email("email@domain.com"))

```
