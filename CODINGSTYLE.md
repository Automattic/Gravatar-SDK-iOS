## Coding Style

Make sure to read [Apple's API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

### Tooling

We use [SwiftFormat](https://github.com/apple/swift-format) to enforce a basic swift format style.

CI will fail if it finds any format issue.

You can run `SwiftFormat` locally with `make lint` to get warnings, or `make swiftformat` to implement the changes automatically.

### URL, ID, API and other initialisms

- Use UPPERCASE everytime we would normally use Capitalized CamelCase.
- Prefix UPPERCASED if it's a type.
- Prefix lowercase everytime the word is a prefix.
- Use lowercase if it's the word alone (and it's not a type).

For example:

```swift
struct URLType {
  let url: URL
  let someURL: URL

  init(_ url: URL)

  func api(with userID: String) -> API
  func api(id: ID) -> API 
}

let urlSomething = URLType(url)
let someURL = URLType(someURL)

```
