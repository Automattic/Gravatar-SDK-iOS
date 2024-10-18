# Gravatar OAuth

Set up the Gravatar OAuth2 to unlock some features.

### Configuration

Some of our REST endpoints require OAuth2 authorization. If you want to call such endpoints directly, please refer to the [Gravatar OAuth](https://docs.gravatar.com/oauth/) documentation. 

Some of our UI features handle the OAuth flow internally, so you don't need to. The Quick Editor handles the OAuth flow internally; you only need to provide the `apiKey`, `clientID`, and `redirectURI`. It uses the "Implicit OAuth" flow behind the scenes, and the token's lifetime is two weeks.

Please refer to the official [Gravatar OAuth](https://docs.gravatar.com/oauth/) documentation to learn more.

#### Steps

1. [Create or Update your Application](https://docs.gravatar.com/oauth/#creating-and-updating-your-application)

The redirect URL should be a valid `https` URL. The server will reject custom URL schemes because they are insecure and prone to being interrupted by other apps. This is a feature of the "Implicit OAuth" flow.

While you can use the custom domain 'wpcom-local-dev' during development (e.g., `wpcom-local-dev://some-authorization-callback`), it's important to note that in production, a valid `https` domain is required.

2. Pass `apiKey`, `clientID`, and `redirectURI` to the SDK.

Call `Configuration.shared.configure(...)` to pass the OAuth secrets. 

```swift
Task {
    await Configuration.shared.configure(
        with: apiKey,
        oauthSecrets: .init(
            clientID: clientID,
            redirectURI: redirectURI
        )
    )
}
``
