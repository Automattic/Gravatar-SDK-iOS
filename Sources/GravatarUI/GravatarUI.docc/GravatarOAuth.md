# Gravatar OAuth

Set up the Gravatar OAuth2 to unlock some features.

### Configuration

Some of our REST endpoints require OAuth2 authorization. If you are looking to call such endpoints directly please refer to the [Gravatar OAuth](https://docs.gravatar.com/oauth/) documentation. 

Some of our UI features take care of OAuth flow internally so you don't need to . The Quick Editor takes care of the OAuth flow internally; you just need to provide the `apiKey`, `clientID`, and `redirectURI`. It uses the "Implicit OAuth" flow behind the scenes, and the token's lifetime is 2 weeks.

Please refer to the official [Gravatar OAuth](https://docs.gravatar.com/oauth/) documentation to find out more.

#### Steps

1. [Create or Update your Application](https://docs.gravatar.com/oauth/#creating-and-updating-your-application)

You need to enter a valid `https` URL as the Redirect URL. Custom URL schemes will be rejected by the server since they are known as insecure because of the known security issues about getting interrupted by other apps. 

Having said that, during the development you can use the custom domain "wpcom-local-dev" if necessary (like: `wpcom-local-dev://some-authorization-callback`). But in production you need to provide a valid `https` domain.

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
