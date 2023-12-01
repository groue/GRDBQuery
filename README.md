# GRDBQuery

**Latest release**: December 1, 2023 • [version 0.8.0](https://github.com/groue/GRDBQuery/tree/0.8.0) • [CHANGELOG](CHANGELOG.md)

**Requirements**: iOS 14.0+ / macOS 11+ / tvOS 14.0+ / watchOS 7.0+ &bull; Swift 5.7+ / Xcode 14+

📖 **[Documentation]**

---

This library helps building SwiftUI applications that access "services", such as a local database, through the SwiftUI environment.

Its main purpose is to help users of the [GRDB] SQLite toolkit. Yet GRDBQuery has no dependency on GRDB: you can use it in other contexts, in a Core Data or Realm application, and generally in any kind of app, as long as you'd like to put the SwiftUI environment to good use. 

## What's in the Box?

GRDBQuery provides two property wrappers:

- With **`@Query`**, SwiftUI views can automatically update their content when the database changes. Generally speaking, `@Query` helps subscribing to Combine publishers defined from the SwiftUI environment:

    ```swift
    /// A view that displays an always up-to-date list of players in the database.
    struct PlayerList: View {
        @Query(PlayersRequest())
        var players: [Player]
        
        var body: some View {
            List(players) { player in Text(player.name) }
        }
    }
    ```

- With **`@EnvironmentStateObject`**, applications can build observable objects that find their dependencies in the SwiftUI environment:

    ```swift
    /// A view that displays the list of players provided by its view model
    struct PlayerList: View {
        @EnvironmentStateObject var viewModel: PlayerListViewModel
        
        init() {
            _viewModel = EnvironmentStateObject { env in
                PlayerListViewModel(database: env.database)
            }
        }
        
        var body: some View {
            List(viewModel.players) { player in Text(player.name) }
        }
    }
    ```
    
    `@EnvironmentStateObject` is a general-purpose property wrapper, akin to the SwiftUI `@Environment`, `@EnvironmentObject`, `@ObservedObject`, and `@StateObject`.
    
    It fits well the view models of the MVVM architecture, as well as dependency injection. 

Both property wrappers can work together, so that developers can run quick experiments, build versatile previews, and also apply strict patterns and conventions. Pick `@Query`, or `@EnvironmentStateObject`, depending on your needs!

## Why GRDBQuery?

**GRDBQuery makes sure SwiftUI views are *immediately* rendered with the content you expect.**

For example, when you display a `List` that animates its changes, you do not want to see an animation for the *initial* state of the list, or to prevent this undesired animation with extra code.

You also want your SwiftUI previews to display the expected values *without having to run them*.

Techniques based on [`onAppear(perform:)`](https://developer.apple.com/documentation/swiftui/view/onappear(perform:)), [`onReceive(_:perform)`](https://developer.apple.com/documentation/swiftui/view/onreceive(_:perform:)) and similar methods suffer from this "double-rendering" problem and its side effects. By contrast, the GRDBQuery property wrappers have you fully covered.

## Documentation

Learn how to use `@Query` and `@EnvironmentStateObject` in the **[Documentation]**.

Check out the **[GRDBQuery demo apps]**, and the **[GRDB demo apps]** for various examples.

## Thanks

🙌 `@Query` was vastly inspired from [Core Data and SwiftUI](https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/) by [@davedelong](https://github.com/davedelong), with [a critical improvement](https://github.com/groue/GRDB.swift/pull/955) contributed by [@steipete](https://github.com/steipete). Many thanks to both of you! `@EnvironmentStateObject` was later introduced because `@Query` does not fit the MVVM architecture. The author sees benefits in both property wrappers.


[GRDB]: http://github.com/groue/GRDB.swift
[GRDB demo apps]: https://github.com/groue/GRDB.swift/tree/master/Documentation/DemoApps
[Documentation]: https://swiftpackageindex.com/groue/GRDBQuery/documentation
[GRDBQuery demo apps]: Documentation
