# ``Gravatar``

Gravatar iOS SDK 

@Metadata {
    @PageImage(
       purpose: icon,
       source: "gravatar-sdk"
   )
}


## Overview

An “avatar” is an image that represents you online—a little picture that appears next to your name when you interact with websites.

A Gravatar is a Globally Recognized Avatar. You upload an image and create your public profile just once, and then when you participate in any Gravatar-enabled site, your Gravatar image and public profile will automatically follow you there.

This SDK will allow you to easily implement the Gravatar services in your project.

### Displaying a Gravatar Image

The easiest way is to use the `UIImageView.gravatar` extension.

```swift
gravatarImageView.gravatar.setImage(email: "user@email.com")
```

For more info check:
- ``GravatarWrapper/setImage(email:placeholder:rating:preferredSize:defaultAvatarOption:options:completionHandler:)``

## Featured

@Links(visualStyle: list) {
    - <doc:GettingStarted>
}

## Topics

### Downloading images

- ``ImageDownloadService``
- ``AvatarService``


### Get user Profile

- ``ProfileService``

### Identifiers

- ``AvatarIdentifier``
- ``ProfileIdentifier``
- ``IdentifierProvider``
- ``Email``
- ``HashID``
