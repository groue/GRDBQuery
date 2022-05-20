# MVVM and Dependency Injection

Learn how the `@EnvironmentStateObject` property wrapper helps building MVVM applications.

## What are we talking about?

Since many programming patterns can be called by the "MVVM" and "Dependency Injection" names, we'll start by making explicit our usage of those terms in this guide. Hopefully you will feel at home.

### MVVM

_MVVM_ stands for "Model-View-ViewModel", and it describes an application architecture that distinguishes three types of objects:

- The _View_ is responsible for the UI. In a SwiftUI application, the view is a SwiftUI View.
- The _ViewModel_ implements application logic, feeds a view with on-screen values, and responds to view events. In a SwiftUI application, the type of a view model is often a class that conforms to the `ObservableObject` protocol.
- The _Model_ feeds a view model. The current state of a game, values loaded from the network, values stored in a local database: these are models.

For example, we can have the `Player` model (a regular Swift struct), the `PlayerListViewModel` (an observable object), and the `PlayerListView` (a SwiftUI view). Naming conventions may vary.

An MVVM application is slightly more complex than a naive or "quick and dirty" app, and there exists reasons for that. The [wikipedia page](https://en.wikipedia.org/wiki/Model-view-viewmodel) describes a few of the MVVM goals. We can add a few technical ones:

- A view model supports many kinds of tests: unit tests, integration tests, end-to-end tests, ui tests, you name it.

- When view models access models through dependency injection, this helps testability. For example, one may want to test a view model in the context of a successful or failing network, or in the context of different database setups (empty database, large database, etc).

- In a SwiftUI application, previews can be seen as quick visual tests. Again, dependency injection makes it possible to run previews in various contexts.  

### Dependency Injection

_Dependency Injection_, or DI, is a programming technique that allows separation of concerns. A typical benefit of DI, in an MVVM application, is to make the developer able to instantiate a view model in the desired context.

For example, the application configures a view model with a real network access, while tests and previews use network mocks in order to leverage the desired behaviors.

In the context of databases, the application uses a database persisted on disk, but tests and previews may prefer light and fast in-memory databases configured as desired.

There exist many available DI solutions for Swift, but this guide focuses on the one that is built-in with SwiftUI: **the SwiftUI environment**. Please refer to the [SwiftUI documentation](https://developer.apple.com/documentation/swiftui/environment) to learn more about the environment.

The SwiftUI environment has great developer ergonomics. For example, it is easy to configure previews:

```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        // Default environment
        MyView(...)

        // Specific environment
        MyView(...).environment(...)
    }
}
```

The SwiftUI environment only applies to view hierarchies, and does not rely on any global or shared DI container. It can't mess with other parts of the application: 

```swift
var body: some View {
    List {
        NavigationLink("Real Stuff") { MyView() }
        NavigationLink("Sandbox") { MyView().environment(...) }
    }
}
```

Using the SwiftUI environment as a DI solution does not force your view models to depend on SwiftUI, and it does not mean that the SwiftUI environment is the only way to access dependencies. In the code snippet below, the view model only depends on Combine (for `ObservableObject`), and does not depend on SwiftUI at all:

```swift
import Combine // for ObservableObject

class MyViewModel: ObservableObject {
    // We don't care if dependencies come from the SwiftUI environment
    // or from any other DI solution:
    init(database: MyDatabase, network: MyNetwork) { ... }
}
```

## Lifetimes of a ViewModel

In a MVVM application, a view relies on its view model for grabbing on-screen values, and handling user actions. Keeping the view model alive is important as long as a view is on screen.

SwiftUI ships with a lot of ready-made property wrappers that control the lifetime of view models, and you are probably already using them in your MVVM SwiftUI applications:
 
- [`@Environment`](https://developer.apple.com/documentation/swiftui/environment) and [`@EnvironmentObject`](https://developer.apple.com/documentation/swiftui/environmentobject) support well view models that outlive the views they feed.

- [`@StateObject`](https://developer.apple.com/documentation/swiftui/stateobject) support view models that live exactly as long as a SwiftUI view.

- [`@ObservedObject`](https://developer.apple.com/documentation/swiftui/observedobject) leaves the lifetime control to some other place in the application: it only propagates a view model through a view hierarchy.

We are lacking something, though. Sure, `@StateObject` can define a view model that lives exactly as long as a SwiftUI view. **Unfortunately, `@StateObject` does not support dependency injection via the SwiftUI environment:**

```swift
struct MyView: View {
    // How to grab dependencies from the SwiftUI environment? 
    @StateObject var viewModel = MyViewModel(???)
}
```

If you've already scratched your head in front of this puzzle, you're at the correct place 🙂. And let's look at the solution below.

## The @EnvironmentStateObject Property Wrapper

``EnvironmentStateObject`` is a property wrapper that instantiates an observable object from the SwiftUI environment:

```swift
struct MyView: View {
    @EnvironmentStateObject var viewModel: MyViewModel
    
    init() {
        _viewModel = EnvironmentStateObject { env in
            MyViewModel(database: env.database, network: env.network)
        }
    }
}
```

In the above sample code, `env.database` and `env.network` are defined with SwiftUI [EnvironmentKey](https://developer.apple.com/documentation/swiftui/environmentkey). See <doc:GettingStarted> for some sample code.

`@EnvironmentStateObject` is quite similar to SwiftUI `@StateObject`, and provides the same essential services:

- `@EnvironmentStateObject` instantiates the observable object right before the initial `body` rendering, and deallocates its when the view is no longer rendered.
- When published properties of the observable object change, SwiftUI updates the parts of any view that depend on those properties.
- Get a `Binding` to one of the observable object’s properties using the `$` operator.

#### Previews

`@EnvironmentStateObject` makes it possible to provide specific dependencies in SwiftUI previews:

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

#### Extra parameters

You can pass extra parameters:

```swift
struct MyView: View {
    @EnvironmentStateObject var viewModel: MyViewModel
    
    init(id: String) {
        _viewModel = EnvironmentStateObject { env in
            MyViewModel(database: env.database, network: env.network, id: id)
        }
    }
}
```

#### Stricter MVVM

Some MVVM interpretations do not allow views to instantiate their view models. In this case, adapt the view initializer:

```swift
struct MyView: View {
    @EnvironmentStateObject var viewModel: MyViewModel
    
    init(_ makeViewModel: @escaping (EnvironmentValues) -> MyViewModel) {
        _viewModel = EnvironmentStateObject(makeViewModel)
    }
}
```

Now you can control view model instantiations:

```swift
struct RootView: View {
    @EnvironmentStateObject var viewModel: RootViewModel

    var body: some View {
        MyView { _ in viewModel.makeMyViewModel() }
    }
}
```

Yet expressive previews are still available:

```swift
struct MyView_Previews: PreviewProvider {
    static var previews: some View {
        // Default database and network
        MyView { env in
            MyViewModel(database: env.database, network: env.network)
        }

        // Specific database, default network
        MyView { env in
            MyViewModel(database: .empty, network: env.network)
        }

        // Specific database and network
        MyView { _ in
            MyViewModel(database: .full, network: .failingMock)
        }
    }
}
```

Finally, `@EnvironmentStateObject` handles view model protocols and generic views pretty well:

```swift
protocol MyViewModelProtocol: ObservableObject { ... }

struct MyView<ViewModel: MyViewModelProtocol>: View {
    @EnvironmentStateObject var viewModel: ViewModel
    
    init(_ makeViewModel: @escaping (EnvironmentValues) -> ViewModel) {
        _viewModel = EnvironmentStateObject(makeViewModel)
    }
}

class MyViewModelA: MyViewModelProtocol { ... }
class MyViewModelB: MyViewModelProtocol { ... }

struct RootView: View {
    @EnvironmentStateObject var viewModel: RootViewModel

    var body: some View {
        HStack {
            MyView { _ in viewModel.makeMyViewModelA() }
            MyView { _ in viewModel.makeMyViewModelB() }
        }
    }
}
```

See the ``EnvironmentStateObject`` documentation for more information. 
