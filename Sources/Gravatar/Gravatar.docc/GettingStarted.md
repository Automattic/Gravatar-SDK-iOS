# Getting started
Install and start using Gravatar for iOS

## Installation

### Swift Package Manager

##### Adding Gravatar SDK to an iOS project in Xcode:
- File > Add Package Dependency
- Search by https://github.com/Automattic/Gravatar-SDK-iOS.git
- Click on `Add Package`

For more info, check the [Apple Docs](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

##### Adding Gravatar to a SPM project:

1. Add the `Gravatar-SDK-iOS` as a dependency of your project. Recommended to use the [latest tagged version](https://github.com/Automattic/Gravatar-SDK-iOS/tags).
2. Add the `Gravatar` product as a dependency of your target.

```swift
let package = Package(
    name: "Package Name",
    dependencies: [
        // 1.
        .package(url: "https://github.com/Automattic/Gravatar-SDK-iOS.git", from: "x.y.z")
    ],
    targets: [
        .executableTarget(
            name: "Target Name",
            dependencies: [
                // 2.
                .product(name: "Gravatar", package: "Gravatar")
            ]
        )
    ]
)
```
### CocoaPods

Add `pod 'Gravatar'` to your target in your `PODFILE`. 

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target 'MyApp' do
    pod 'Gravatar'
end
```

## Getting Started

### Downloading a user Gravatar image

To set a gravatar image in a `UIImageView` (or a `UIImageView subclass`), the easiest way is to use the `.gravatar` extension:

```swift
import Gravatar

// [...]

avatarImageView.gravatar.setImage(email: "some@email.com") { result in
    switch result {
    case .success(let result):
        print("The image view is already displaying the avatar! 🎉")
    case .failure(let error):
        print(error)
    }
}
```

You can also download the Gravatar image using the `AvatarService` to download an image:

```swift
import Gravatar

// [...]

Task {
    await fetchAvatar(with: "some@email.com")
}

func fetchAvatar(with email: String) async {
    let service = AvatarService()

    do {
        let result = try await service.fetchImage(with: email)
        updateAvatar(with: result.image) 
    } catch {
        print(error)
    }
}

@MainActor
func updateAvatar(with image: UIImage) {
    avatarImageView.image = image
}
```

### Download Profile information

You can get the public information of a Gravatar using an instance of ``ProfileService``.

```swift
import Gravatar

// [...]

Task {
    await fetchProfile(with: "some@email.com")
}

func fetchProfile(with email: String) async {
    let service = ProfileService()

    do {
        let profile = try await service.fetch(with: .email(email))
        updateUI(with: profile)
    } catch {
        print(error)
    }
}

@MainActor
func updateUI(with profile: Profile) {
    /// Update UI elements...
}
```

#### Getting full Profile information

Use the ``Configuration`` class to set an api key, which will be used to authorise the request of a full Gravatar profile.

```swift
await Configuration.shared.configure(with: apiKey)
```

See ``Profile`` to know which fields are public, and whichones need authorization.
