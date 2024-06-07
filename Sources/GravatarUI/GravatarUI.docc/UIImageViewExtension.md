# UIImageView extension

Use UIImageView extension to easily set an avatar.

### Set an avatar via email

To set an avatar on your own `UIImageView` directly (or a `UIImageView subclass`), the easiest way is to use the `.gravatar` extension:

```swift
import GravatarUI

// [...]

let avatarImageView = UIImageView()

do {
    try await avatarImageView.gravatar.setImage(avatarID: .email("some@email.com"))
    print("The image view is already displaying the avatar! 🎉")
} catch {
    print(error)
}
```

#### Extra options

You can pass an `option` parameter of type [``ImageSettingOption``] to customize the operaton.

```swift
import GravatarUI

// [...]

let placeholder = UIImage(named: "...")
let avatarImageView = UIImageView()

do {
    try await avatarImageView.gravatar.setImage(
        avatarID: .email(""),
        placeholder: placeholder,
        options: [.forceRefresh,
                  .transition(.fade(0.3)),
                  .imageCache(MyCache.shared)] // MyCache should conform to ``ImageCaching``.
    )
    print("The image view is already displaying the avatar! 🎉")
} catch {
    print(error)
}
```

### Show an activity indicator

You can show an activity indicator on the UIImageView during the download.

```swift
import GravatarUI

// [...]

let avatarImageView = UIImageView()

do {
    // You can use the system activity indicator by:
    avatarImageView.gravatar.activityIndicatorType = .activity
    
    // and then access it by:
    avatarImageView.gravatar.activityIndicator?.view.tintColor = .blue
    
    // Or, you can use a fully custom activity indicator:
    avatarImageView.gravatar.activityIndicatorType = .custom(MyActivityIndicator()) // `MyActivityIndicator` conforms to ``ActivityIndicatorProvider``

    try await avatarImageView.gravatar.setImage(avatarID: .email("some@email.com"))
    print("The image view is already displaying the avatar! 🎉")
} catch {
    print(error)
}
```

### Set an avatar via URL

```swift
import GravatarUI

// [...]

let avatarImageView = UIImageView()
let options = AvatarQueryOptions(preferredPixelSize: 120,
                                 rating: .restricted,
                                 defaultAvatarOption: .mysteryPerson)

// `AvatarURL` takes care of removing the query parameters in the initial URL and reconstructing the URL based on the given options.

guard let url = URL(string: "https://gravatar.com/avatar/b815b4f3f5e4be2256bce9e25eac7714?r=pg&s=150"),
      let avatarURL = AvatarURL(url: url, options: options)?.url else {
    // handle the unexpected state
}
let placeholder = UIImage(named: "...")

do {
    try await avatarImageView.gravatar.setImage(with: avatarURL, placeholder: placeholder)
    print("The image view is already displaying the avatar! 🎉")
} catch {
    print(error)
}
```
