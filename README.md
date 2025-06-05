# Gravatar
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAutomattic%2FGravatar-SDK-iOS%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Automattic/Gravatar-SDK-iOS) 
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAutomattic%2FGravatar-SDK-iOS%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Automattic/Gravatar-SDK-iOS)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)


Gravatar SDK is a Swift library that allows you to integrate [Gravatar](https://gravatar.com/) features into your own iOS applications.

If you're also looking to integrate Gravatar in your Android app, check out our [Gravatar SDK for Android](https://github.com/Automattic/Gravatar-SDK-android)!

## Features

#### Core services:
- [Avatar URL calculator](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/5.-AvatarURLCalculator) based on email, email hash, and several [query options](https://docs.gravatar.com/general/images/).
- [Avatar downloading](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/2.-downloadingavatar) based on [email](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/2.-downloadingavatar#Download-Avatar-via-email) or [url](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/2.-downloadingavatar#Download-Avatar-via-email).
  - [Built-in image cache](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/2.-downloadingavatar#Providing-a-custom-Image-Cache) (with the ability to inject your own cache).
- [Avatar uploading](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/3.-uploadingavatar) to a [Gravatar](https://gravatar.com/) account.
- [Gravatar profile fetching](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/4.-fetchingprofile) based on email.

#### Gravatar UI:
- [Display a profile view](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/profileviews) or [an avatar](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/avatarviewarticle/) through ready-to-use UI components.
- [Quick Editor](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/quickeditorarticle): This customizable sheet allows you to manage your avatar and Gravatar profile. 
  - Select an existing avatar or upload a new one.
  - Manage and update the "About" section of your Gravatar profile.
- [`UIImageView` extension](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/uiimageviewextension/) to directly set the downloaded image.
- [SwiftUI Avatar](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/avatarviewarticle/) component(`AvatarView`)

## Tutorials
- [Profile views as contacts list](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/tutorials/gravatarui/contactslist/)
- [Adding the Quick Editor to a SwiftUI View](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/tutorials/gravatarui/quickeditor/)

## Installation

### Create an API key

Follow the steps in the [REST API documentation](https://docs.gravatar.com/api/profiles/rest-api/) to create a Gravatar API key. You can use some features without an API Key, but you’ll receive limited information, and stricter rate limits may apply, so we highly encourage you to create one in the [developer portal](https://gravatar.com/developers/).

For installation instructions and examples, see out [getting started](Sources/Gravatar/Gravatar.docc/1.%20GettingStarted.md) guide.

## Documentation

You can find some detailed articles, tutorials and API docs via these links:

- [Gravatar docs](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/)
  - [Getting started](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/1.-gettingstarted/)
      - Install and start using Gravatar for iOS
  - [Downloading an Avatar](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/2.-downloadingavatar/)
    - Download an avatar provided by Gravatar.
  - [Uploading an Avatar](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/3.-uploadingavatar/)
    - Let a user to update their avatar.
  - [Fetching Profile Information](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/4.-fetchingprofile/)
    - Fetch a public Gravatar profile.
  - [AvatarURL Calculator](https://automattic.github.io/Gravatar-SDK-iOS/gravatar/documentation/gravatar/5.-avatarcalculator/)
    - Create and validate Gravatar image URLs
- [GravatarUI docs](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/)
  - [Getting started](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/gettingstarted/)
    - Install and start using GravatarUI for iOS
  - [UIImageView extension](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/uiimageviewextension/)
    - Use UIImageView extension to easily set an avatar.
  - [SwiftUI AvatarView](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/avatarviewarticle/)
    - A customizable SwiftUI component to easily set an avatar.
  - [Profile view designs](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/profileviews/)
    - We offer a variety of profile view layouts for different usecases.
  - [Gravatar OAuth](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/gravataroauth/)
    - Set up the Gravatar OAuth2 to unlock some features.
  - [Quick Editor](https://automattic.github.io/Gravatar-SDK-iOS/gravatarui/documentation/gravatarui/quickeditorarticle/)
    - This customizable sheet allows users to update their avatars. Available for both UIKit and SwiftUI.

## Author

Gravatar

## Coding Style

Check out our [Coding Style guide](CODINGSTYLE.md).

## Contributing

Read our [Contributing Guide](CONTRIBUTING.md) to learn about reporting issues, contributing code, and more ways to contribute.

## License

Gravatar-SDK-iOS is an open source project covered by the [Mozilla Public License Version 2.0](LICENSE.md).
