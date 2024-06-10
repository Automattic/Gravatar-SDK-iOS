#  Fetching Profile Information

Fetch a public Gravatar profile. 

Use ``ProfileService`` to fetch profile information.

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

#### Getting full Profile information and better rate limits

Follow the steps in the [REST API documentation](https://docs.gravatar.com/api/profiles/rest-api/) to create a Gravatar API key. You can use some features without an API Key, but you’ll receive limited information, and stricter rate limits may apply. So we highly encourage you to create one in the [developer portal](https://gravatar.com/developers/).

Use the ``Configuration`` class to set an api key, which will be used to authorise the request.

```swift
await Configuration.shared.configure(with: apiKey)
```

See ``Profile`` to know which fields are public, and which ones need `apiKey` authorization.
