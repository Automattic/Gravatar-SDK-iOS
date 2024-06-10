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

## Articles

@Links(visualStyle: list) {
    - <doc:UIImageViewExtension>
}

@Links(visualStyle: list) {
    - <doc:ProfileViews>
}
