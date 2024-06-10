#  Uploading an Avatar

Let a user to update their avatar.

You can provide a way to upload a new avatar for your users who have a Gravatar account.

At the moment, Gravatar uses WordPress.com OAuth2 access token. Thus, you need a WordPress.com access token to update a user's avatar. Check out [the documentation](https://developer.wordpress.com/docs/oauth2/) to find more about how to get consent from the user and how to retrieve an access token. 

Use ``AvatarService`` to upload an avatar.

```swift
import Gravatar

// [...]

let service = AvatarService()
let image: UIImage = // image of choice from the user
let accessToken = // WordPress.com OAuth2 access token 
do {
   try await service.upload(image, email: Email("email@domain.com"), accessToken: accessToken)
} catch {
    // handle error
}

``
