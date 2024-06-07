#  Downloading an Avatar

Download an avatar provided by Gravatar.

## Download Avatar via email

Use the ``AvatarService`` to download an avatar image:

```swift
import Gravatar

// [...]

Task {
    await fetchAvatar(with: "some@email.com")
}

func fetchAvatar(with email: String) async {
    let service = AvatarService()

    do {
        let result = try await service.fetchImage(with: .email(email))
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

### Download Options

Check out ``ImageDownloadOptions`` and [the backend documentation](https://docs.gravatar.com/api/avatars/images/). Pass your preferences about the avatar size, rating etc. Even though each option has a default value we highly encourage you to investigate the provided documentation and set your own values because they can have big impact on the result.

```swift
import Gravatar

let service = AvatarService()
let options = ImageDownloadOptions(preferredSize: .points(50),
                                   rating: .general,
                                   forceRefresh: false,
                                   defaultAvatarOption: .mysteryPerson)
let result = try await service.fetch(with: .email("email@domain.com"), options: options)

```

#### Providing a custom `ImageProcessor`

If you want to control the way the downloaded `Data` is converted into a `UIImage` you can implement your own ``ImageProcessor``.


```swift
import Gravatar

struct CustomImageProcessor: ImageProcessor {
    func process(_ data: Data) -> UIImage? {
        let result: UIImage?
        // work on the data
        // result = ...
        return result
    }
}

let service = AvatarService()
let options = ImageDownloadOptions(processingMethod: .custom(processor: CustomImageProcessor()))
let result = try await service.fetch(with: .email("email@domain.com"), options: options)

```

## Download Avatar via URL

Sometimes you may need to download the Avatar based on a URL. You may also need to apply different options on the URL.

Use ``AvatarURL`` and ``ImageDownloadService`` to achieve this.


```swift
import Gravatar

// [...]

let options = AvatarQueryOptions(preferredPixelSize: 120,
                                 rating: .restricted,
                                 defaultAvatarOption: .mysteryPerson)

// ``AvatarURL` takes care of removing the query parameters in the initial URL and reconstructing the URL based on the given options.

guard let url = URL(string: "https://gravatar.com/avatar/b815b4f3f5e4be2256bce9e25eac7714?r=pg&s=150"),
      let avatarURL = AvatarURL(url: url, options: options)?.url else {
    // handle the unexpected state
}

let service = ImageDownloadService()
let result = try await service.fetchImage(with: avatarURL)

```

