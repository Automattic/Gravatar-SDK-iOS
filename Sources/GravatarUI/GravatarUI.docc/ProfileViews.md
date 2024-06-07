# Profile view designs

We offer a variety of profile view layouts for different usecases. 

As an example, you can use a ```ProfileView``` to be added to your UI in this way:

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

#### Currently we offer 4 styles:

``ProfileViewConfiguration/Style/standard`` (underlying type: ``ProfileView``)

![](profileView.view)

``ProfileViewConfiguration/Style/summary`` (underlying type: ``ProfileSummaryView``)

![](profileSummaryView.view)

``ProfileViewConfiguration/Style/large`` (underlying type: ``LargeProfileView``)

![](largeProfileView.view)

``ProfileViewConfiguration/Style/largeSummary`` (underlying type: ``LargeProfileSummaryView``)

![](largeProfileSummaryView.view)

### How to use a `ProfileViewConfiguration` to manage the view

``ProfileViewConfiguration`` is a `UIContentConfiguration` and it allows you to create or update the content view.

```swift
import GravatarUI

let profile = try await service.fetch(with: .email("user@email.com"))
var config = ProfileViewConfiguration.standard()

// customize it for your neeeds:
config.palette = .system // or .custom(paletteProvider) to pass your own `Palette`.
config.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
config.profileButtonStyle = .view
config.delegate = // delegate to handle events
config.model = profile

let view = config.makeContentView()

// Update the config as needed.
// Let's fetch a different profile for example.

// Clear the model and start loading indicators:
config.model = nil
config.isLoading = true
view.configuration = config

// Fetch the profile:
let profile = try await service.fetch(with: .email("other_user@email.com"))

// Set the model and stop loading indicators:
config.model = profile
config.isLoading = true
view.configuration = config

```
#### How to apply a custom color palette

See ``PaletteType`` for available color palettes. You can also pass your own ``Palette`` if you need different colors.

```swift
import GravatarUI

let myPalette1 = Palette(...)
let myPalette2 = Palette(...)
let myPalette3 = Palette(...)

let paletteProvider = { 
   switch currentTheme { 
    case .theme1: 
      return myPalette1
    case .theme2: 
      return myPalette2
    case .theme2: 
      return myPalette3
   }
}

var config = ProfileViewConfiguration.standard()
config.paletteType = .custom(paletteProvider)

let view = config.makeContentView()

```

