# SwiftUI AvatarView

A customizable SwiftUI component to easily set an avatar.

### Set an avatar via email

You can use the `AvatarView` to quickly set an avatar and automatically cache it.

```swift
import GravatarUI

// [...]

// Create an `AvatarURL`
var avatarURL: AvatarURL? {
    AvatarURL(
        with: .email("email@domain.com"),
        options: .init(
            preferredSize: .points(80),
            defaultAvatarOption: .status404
        )
    )
}

// [...]

var body: some View {
    // Create AvatarView
    AvatarView(
        url: avatarURL?.url,
        placeholder: Image("...").renderingMode(.template), // pass a placeholder if you prefer
    )
    .shape(RoundedRectangle(cornerRadius: 8),
           borderColor: .purple,
           borderWidth: 2) // A modifier that helps with applying shape and border.
    .foregroundColor(.purple) // Sets the placeholder tint
    .frame(width: 80, height: 80)
}

```

#### Extra options

Here are some optional parameters for further customization:

- cache: A cache that conforms to ``ImageCaching``.
- urlSession: URLSession to manage the network tasks.
- forceRefresh: A Binding boolean to skip the cache and fetch the most up to date avatar.
- loadingView: A `View to display during loading.
- transaction: A `Transaction` to animate setting the image.

```swift
import GravatarUI

@State var forceRefresh: Bool = false

// [...]

var body: some View {
    AvatarView(
        url: avatarURL?.url,
        placeholder: Image("...").renderingMode(.template),
        cache: MyImageCache.shared, // A cache that conforms to ``ImageCaching``
        urlSession: mySession, // A custom URL session
        forceRefresh: $forceRefresh, // skip the cache if needed
        loadingView: {
            ProgressView() // A circular progress view to indicate loading activity
                .progressViewStyle(CircularProgressViewStyle())
        },
        transaction: Transaction(animation: .easeInOut(duration: 0.3)) // an animation for transitioning into the new image
    )
    .shape(RoundedRectangle(cornerRadius: 8),
           borderColor: .purple,
           borderWidth: 2) // A modifier that helps with applying shape and border.
    .foregroundColor(.purple) // Sets the placeholder tint
    .frame(width: 80, height: 80)
}

```
