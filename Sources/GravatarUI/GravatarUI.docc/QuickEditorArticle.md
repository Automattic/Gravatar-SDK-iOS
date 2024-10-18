# Quick Editor

This customizable sheet allows users to update their avatars. Available for both UIKit and SwiftUI.

### Quick Editor Preview

Here's how it looks like:

![](vertical-large.png)

It is possible to initially display it as a bottom sheet and let the user to expand it.

![](vertical-medium-expandable.png)

Also possible to scroll the avatars collection horizontially:

![](horizontal-intrinsic-height.png)


### Quick Editor - SwiftUI

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
            scope: .avatarPicker(.init(contentLayout: .horizontal)),
            avatarUpdatedHandler: {
                // informs that the avatar has changed
            },
            onDismiss: {
                // sheet was dismissed
            }
        )
    }
    .preferredColorScheme(.light) //set the preferred color scheme if you like, or omit this line to let the system settings apply.
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
            authToken: authToken,  // Pass the auth token
            scope: .avatarPicker(.init(contentLayout: .horizontal)),
            avatarUpdatedHandler: {
                // informs that the avatar has changed
            },
            onDismiss: {
                // sheet was dismissed
            }
        )
    }
    .preferredColorScheme(.light) //set the preferred color scheme if you like, or omit this line to let the system settings apply.
}
```

Refer to ``AvatarPickerContentLayout`` to see all the content layout options.

### Quick Editor - UIKit

Similarly, ``QuickEditorPresenter`` can be used to display the QuickEditor in UIKit.

```swift
import GravatarUI

// [...]

let presenter = QuickEditorPresenter(
    email: Email("email@domain.com"),
    scope: .avatarPicker(AvatarPickerConfiguration(contentLayout: .horizontal)),
    configuration: .init(
        interfaceStyle: colorScheme
    )
)
presenter.present(in: self, 
                  onAvatarUpdated: { [weak self] in
                      // Informs that the avatar has changed
                  } , onDismiss: { [weak self] in
                      // sheet was dismissed
                  })
```

### Delete the OAuth token

SDK stores the OAuth token securely in the Keychain. You can call the below method to remove it from the Keychain. It would be convenient to do so when a user logs out from the app.

```swift
import GravatarUI

// [...]

OAuthSession.deleteSession(with: Email("email@domain.com"))

```
