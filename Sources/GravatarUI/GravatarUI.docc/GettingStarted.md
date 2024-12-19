# Getting started
Install and start using GravatarUI for iOS

## Installation

### Swift Package Manager

##### Adding Gravatar SDK to an iOS project in Xcode:
- File > Add Package Dependency
- Search by https://github.com/Automattic/Gravatar-SDK-iOS.git
- Click on **Add Package**

For more info, check the [Apple Docs](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

##### Adding GravatarUI to a SPM project:

Select a package version. Recommended to use the [latest tagged version](https://github.com/Automattic/Gravatar-SDK-iOS/tags).

```swift
.package(url: "https://github.com/Automattic/Gravatar-SDK-iOS.git", from: "x.y.z")

```

Add the `GravatarUI` product as a dependency for your target:

```swift
.product(name: "GravatarUI", package: "gravatar-sdk-ios")
```

### CocoaPods

Add `pod 'GravatarUI'` to your target in your `PODFILE`. 

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target 'MyApp' do
    pod 'GravatarUI'
end
```

## Running the demo app.

The demo application included in this SDK is designed to showcase the core functionalities and provide a starting point for integrating the SDK into your project. It offers a practical, hands-on way to explore key features and test configurations in a controlled environment.

While some features are ready to be tested out of the box, others require additional setup, such as creating a Gravatar Application on the developer portal, and configuring the secrets in the Demo app.

### To access the full featured demo app:
1. Create a [Gravatar Application](https://docs.gravatar.com/oauth/#creating-and-updating-your-application).
2. To have access to the Quick Editor through OAuth, set the following `Callback URI`:
  - `https://gravatar.com/iosdemo/oauth/callback` 
3. Copy the `API key`, `Client ID`, and `Callback URI` to be pasted on the demo app.
4. After building the Demo app for the first time, a file `Secrets.swift` is going to be automatically created. Fill up the constants of this file with the secrets from the previous step.
5. Now you have access to Full Profile and Quick Editor in the Demo app 🎉


## Articles

@Links(visualStyle: list) {
    - <doc:UIImageViewExtension>
    - <doc:AvatarViewArticle>
    - <doc:ProfileViews>
    - <doc:GravatarOAuth>
    - <doc:QuickEditorArticle>
}
