# ``GravatarUI``

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

This SDK offers an easy way to present Gravatar user's visually in your app.

### How to:

We offer a variety of profile view layouts for different usecases. As an example, you can use a ```ProfileView``` to be added to your UI in this way:

```swift
// 1. Get an instance of a ProfileService
let service = ProfileService()
// 2. Get the user's profile:
let profile = try await service.fetch(with: .email("user@email.com"))
// 3. Get the instance of a ProfileView:
let profileView = ProfileView()
// 4. Set the profile to the view:
profileView.update(with: profile)
```
`ProfileView` will look like this:
![Profile view example](profileView.view)

## Tutorials

@Links(visualStyle: list) {
    - <doc:ContactsList>
}

## Topics

### Profile views

- ``ProfileView``
- ``ProfileSummaryView``
- ``LargeProfileView``
- ``LargeProfileSummaryView``
