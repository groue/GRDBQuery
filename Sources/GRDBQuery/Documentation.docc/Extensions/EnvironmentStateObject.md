# ``GRDBQuery/EnvironmentStateObject``

A property wrapper that instantiates an observable object from the
SwiftUI environment.

## Overview

`@EnvironmentStateObject` is similar to SwiftUI `@StateObject`, and provides the same essential services:

- `@EnvironmentStateObject` instantiates the observable object right before the initial `body` rendering, and deallocates its when the view is no longer rendered.
- When published properties of the observable object change, SwiftUI updates the parts of any view that depend on those properties.
- Get a `Binding` to one of the observable object’s properties using the `$` operator.

What `@EnvironmentStateObject` brings on top of `@StateObject` is the ability to instantiate the observable object from the SwiftUI environment.

**If you do not need to instantiate your observable object from the SwiftUI environment**, then `@EnvironmentStateObject` is not what you need. Just use the plain `@StateObject` instead.

**If the lifetime of your observable object is different from the one `@StateObject` would provide**, then `@EnvironmentStateObject` is not what you need. Have a look at `@ObservedObject`, `@EnvironmentObject`, etc.

> Important: Just as `@StateObject`, `@EnvironmentStateObject` ties the lifetime of the observable object to the lifetime of the view identity. Once the observable object has been instantiated (right before the initial `body` rendering), changes in environment values or other parameters are just ignored.
>
> Just like `@StateObject`, you can force a new instantiation of the observable object by changing the view identity.

## Usage

A typical setup starts from an observable object that requires some dependencies (for example, access to the network, or to a database):

```swift
import Combine // For ObservableObject

class MyModel: ObservableObject {
    let fieldTitle: String
    @Published var fieldValue: String

    init(database: MyDatabase, network: MyNetwork) { ... }

    func save() { ... }
}
```

The application defines an [EnvironmentKey](https://developer.apple.com/documentation/swiftui/environmentkey) for dependencies in the SwiftUI environment:

```swift
import SwiftUI

extension EnvironmentValues {
    var database: MyService { ... }
    var network: MyNetwork { ... }
}
```

Now a view can use the `@EnvironmentStateObject` property wrapper:

```swift
import GRDBQuery
import SwiftUI

struct MyView: View {
    @EnvironmentStateObject private var model: MyModel

    init() {
        _model = EnvironmentStateObject { env in
            MyModel(database: env.database, network: env.network)
        }
    }

    var body: some View {
        HStack {
            TextField(viewModel.fieldTitle, text: $model.fieldValue)
            Button("save") { viewModel.save() }
        }
    }
}
```

### Configuring the Observable Object

When the observable object needs some extra configuration, update the initializers:

```swift
class MyModel: ObservableObject {
    init(database: MyDatabase, network: MyNetwork, id: String) { ... }
}

struct MyView: View {
    @EnvironmentStateObject private var model: MyModel

    init(id: String) {
        _model = EnvironmentStateObject { env in
            MyModel(database: env.database, network: env.network, id: id)
        }
    }
}
```

### Decoupling the View from its Observable Object

You can have the container view responsible for instantiating the observable object:

```swift
struct MyView: View {
    @EnvironmentStateObject private var model: MyModel

    init(_ makeModel: @escaping (EnvironmentValue) -> MyModel) {
        _model = EnvironmentStateObject(makeModel)
    }
}

struct RootView: View {
    var body: some View {
        MyView { env in MyModel(database: env.database, network: env.network) }
    }
}
```

This technique helps observable objects create other ones:

```swift
struct RootView: View {
    @EnvironmentStateObject private var rootModel: RootModel

    var body: some View {
        MyView { _ in rootModel.makeMyModel() }
    }
}
```

This technique is also useful for generic views that accept various types of observable objects:

```swift
protocol MyModelProtocol: ObservableObject { ... }

struct MyView<Model: MyModelProtocol>: View {
    @EnvironmentStateObject private var viewModel: Model

    init(_ makeModel: @escaping (EnvironmentValues) -> Model) {
        _viewModel = EnvironmentStateObject(makeModel)
    }
}

class MyModelA: MyModelProtocol { ... }
class MyModelB: MyModelProtocol { ... }

struct RootView: View {
    @EnvironmentStateObject private var viewModel: RootModel

    var body: some View {
        HStack {
            MyView { _ in viewModel.makeMyModelA() }
            MyView { _ in viewModel.makeMyModelB() }
        }
    }
}
```

### SwiftUI Previews

`@EnvironmentStateObject` supports SwiftUI previews very well. It instantiates observable objects with the expected environment values. For example:

```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        // Default database and network
        MyView()

        // Specific database, default network
        MyView().environment(\.database, .empty)

        // Specific database and network
        MyView()
            .environment(\.database, .full)
            .environment(\.network, .failingMock)
    }
}
```

### MVVM

`@EnvironmentStateObject` exists as a support for MVVM applications that use the SwiftUI environment as a solution for dependency injection. See <doc:MVVM> for more information.

## Topics

### Creating an Environment State Object

- ``init(_:)``

### Getting the Value

- ``wrappedValue``
- ``projectedValue``
- ``Wrapper``

### SwiftUI Integration

- ``update()``
