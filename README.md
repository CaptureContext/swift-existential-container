# swift-existential-container

[![CI](https://github.com/CaptureContext/swift-existential-container/actions/workflows/ci.yml/badge.svg)](https://github.com/CaptureContext/swift-existential-container/actions/workflows/ci.yml) [![SwiftPM 6.0](https://img.shields.io/badge/swiftpm-6.0-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/platforms-all-ED523F.svg?style=flat) [![@capture_context](https://img.shields.io/badge/contact-@capture__context-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

> [!NOTE]
> _You don't need this package or explicit `_openExistential` now, because [SE-0352](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md) introduced implicit open existentials and any of examples can be acheived with plain generic functions that now can open existentials implicitly. Example with AnyView can be simplified even more with [SE-0335](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md)_ 💁‍♂️

## Usage

Lets review how to create `SwiftUI.AnyView` from `Any`

- Declare a protocol with desired features you want to open, it can be private to avoid namespace pollution

```swift
private protocol AnyViewConforming {
  // This variable could also be a function
  // purpose of this declaration is just to
  // provide local access to desired functionality
  var body: AnyView { get }
}
```

Then we should conditionally conform `ExistentialBox` to given protocol

```swift
// ExistentialBox.Content should conform/inherit from a type
// that can provide us with needed API to implement our conformance
extension ExistentialBox: AnyViewConforming where Content: View {
  fileprivate var body: AnyView { .init(self.content) }
}
```

> `content` _is the only property of_ `ExistentialBox`

After that we're all set to implement our public API using `open` function

```swift
extension AnyView {
  init?(any: Any) {
    guard let content = open(any, as: AnyViewConforming.self, \.content)
    else { return nil }
    self = content
  }
}
```

### Final code

```swift
private protocol AnyViewConforming {
  var body: AnyView { get }
}

extension ExistentialBox: ViewConforming where Content: View {
  fileprivate var body: AnyView { .init(content) }
}

extension AnyView {
  init?(any: Any) {
    guard let content = open(any, as: \AnyViewConforming.body) else { return nil }
    self = content
  }
}
```

### Pure _openExistential example

```swift
protocol AnyViewBoxProtocol {
  var body: AnyView { get }
}

struct AnyViewBox<Content> {
  var content: Content
}

extension AnyViewBox: AnyViewBoxProtocol where Content: View {
  var body: AnyView { AnyView(content) }
}

extension AnyView {
    init?(any: Any) {
      func unbox<T>(_ value: T) -> AnyView? { 
        (AnyViewBox(content: value) as? AnyViewBoxProtocol).map(\.body)
      }
      
      guard let value = _openExistential(any, do: unbox) else { return nil}
      self = value
    }
}
```

### [SE-0352](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md)

```swift
extension AnyView {
  @MainActor
  init?(any: Any) {
    func open<T: View>(_ view: T) -> AnyView { .init(view) }
    guard let anyView = any as? (any View) else { return nil }
    self = open(anyView)
  }
}
```

### [SE-0335](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md)

```swift
extension View {
  fileprivate func eraseToAnyView() -> AnyView { AnyView(self) }
}
```

It's enough, but the call site will look like this `(anyValue as? (any View))?.eraseToAnyView()` which is not very ergonomic and you may still want an AnyView extension

```swift
extension AnyView {
  @MainActor
  init?(any: Any) {
    guard let anyView = any as? (any View) else { return nil }
    self = anyView.eraseToAnyView()
  }
}
```

### APIs

- Short calls:
  
  > _Imo the most ergonomic, but cause type ambiguity if used in `ExistentialBox` extensions_
  
  - `open(value, as: MyProtocol.self) { $0.myProtocolMethod() }`
  - `open(value, as: MyProtocol.self, with: \.myProtocolProperty)`
  - `open(value, with: \MyProtocol.myProtocolProperty)`
- Verbose calls:
  > _`ExistentionalContainer` is module name, this prefix can be omitted if no type ambiguity occure at the call site, however I'd prefer proxy call in that case_
  - `ExistentionalContainer.open(value, as: MyProtocol.self) { $0.myProtocolMethod() }`
  - `ExistentionalContainer.open(value, as: MyProtocol.self, with: \.myProtocolProperty)`
  - `ExistentionalContainer.open(value, with: \MyProtocol.myProtocolProperty)`
- Proxy calls:

  > _Should not cause type ambiguity in any context, but a bit longer than short calls_

  - `ExistentialBox<MyProtocol>.open(value) { $0.myProtocolMethod() }`
  - `ExistentialBox<MyProtocol>.open(value, with: \.myProtocolProperty)`
- Unreasonable proxy calls:
  > _Why would u use a longer version when it's just longer versions of proxy calls and may cause type ambiguity when used in ExistentialBox extensions_ 🤪
  - `ExistentialBox.open(value, as: MyProtocol.self,) { $0.myProtocolMethod() }`
  - `ExistentialBox.open(value, as: MyProtocol.self, with: \.myProtocolProperty)`

## Installation

### Basic

You can add ExistentialContainer to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/swift-existential-container"`](https://github.com/capturecontext/swift-existential-container) into the package repository URL text field
3. Choose products you need to link them to your project.

### Recommended

If you use SwiftPM for your project structure, add ExistentialContainer to your package file. 

```swift
.package(
  url: "git@github.com:capturecontext/swift-existential-container.git", 
  .upToNextMajor(from: "1.0.1")
)
```

or via HTTPS

```swift
.package(
  url: "https://github.com:capturecontext/swift-existential-container.git", 
  .upToNextMajor("1.0.1")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "ExistentialContainer", 
  package: "swift-existential-container"
)
```

## License

This library is released under the MIT license. See [LICENSE](./LICENSE) for details.
