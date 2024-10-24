# Gravatar OAuth

Set up the Gravatar OAuth2 to unlock some features.

### Configuration

Some of our REST endpoints require OAuth2 authorization. If you want to call such endpoints directly, please refer to the [Gravatar OAuth](https://docs.gravatar.com/oauth/) documentation. 

Some of our UI features handle the OAuth flow internally, so you don't need to—for example, the Quick Editor. You only need to provide the `apiKey`, `clientID`, and `redirectURI`. It uses the "Implicit OAuth" flow behind the scenes, and the token's lifetime is two weeks.

Please refer to the official [Gravatar OAuth](https://docs.gravatar.com/oauth/) documentation to learn more.

#### Steps

1. [Create or Update your Application](https://docs.gravatar.com/oauth/#creating-and-updating-your-application)

> Keep in mind that you need to use the https scheme. Internally, QuickEditor uses Implicit OAuth flow (response_type=token) and for security reasons, the server doesn't allow custom URL schemes.

2. Pass `apiKey`, `clientID`, and `redirectURI` to the SDK.

Call `Configuration.shared.configure(...)` to pass the OAuth secrets. 

> For the sake of this example let's assume the redirect URL is `https://yourhost.com/redirect-url`.

```swift
Task {
    await Configuration.shared.configure(
        with: apiKey,
        oauthSecrets: .init(
            clientID: clientID,
            redirectURI: "https://yourhost.com/redirect-url"
        )
    )
}
```

3. Handle the universal link callback

The OAuth flow calls the `redirectURI` you have provided in the previous step which then triggers `UIApplicationDelegate`.`application(_:continue:restorationHandler:)`. Here, you need to call `OAuthSession.handleCallback(...)` with the callback URL. This way, the SDK captures the access token to be used in the authorization requiring API calls.

```swift

class AppDelegate: UIApplicationDelegate {

    // [...]

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
            let path = components.path else { return }

        if path == "/redirect-url" { // Replace with your own OAuth redirectURI path
            Task {
                await GravatarUI.OAuthSession.handleCallback(incomingURL)
            }
        }
    }
}

```

That's it. Now you are ready to use the <doc:QuickEditorArticle>.
