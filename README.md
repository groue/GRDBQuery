# GRDBQuery

**Latest release**: March 15, 2025 • [version 0.11.0](https://github.com/groue/GRDBQuery/tree/0.11.0) • [CHANGELOG](CHANGELOG.md)

**Requirements**: iOS 14.0+ / macOS 11+ / tvOS 14.0+ / watchOS 7.0+ &bull; Swift 6+ / Xcode 16+

📖 **[Documentation]**

---

GRDBQuery helps SwiftUI applications access a local SQLite database through [GRDB] and the SwiftUI environment.

It comes in two flavors:

- The `@Query` property wrapper allows SwiftUI views to directly read and observe the database:

    ```swift
    /// Displays an always up-to-date list of database players.
    struct PlayerList: View {
        @Query(PlayersRequest()) var players: [Player]
        
        var body: some View {
            List(players) { player in Text(player.name) }
        }
    }
    ```

- The `@EnvironmentStateObject` property wrapper helps building `ObservableObject` models from the SwiftUI environment:

    ```swift
    /// Displays an always up-to-date list of database players.
    struct PlayerList: View {
        @EnvironmentStateObject var model: PlayerListModel = []
        
        init() {
            _model = EnvironmentStateObject { env in
                PlayerListModel(databaseContext: env.databaseContext)
            }
        }
        
        var body: some View {
            List(model.players) { player in Text(player.name) }
        }
    }
    ```

Both techniques can be used in a single application, so that developers can run quick experiments, build versatile previews, and also apply strict patterns and conventions. Pick `@Query`, or `@EnvironmentStateObject`, depending on your needs!

## Documentation

Learn how to use `@Query` and `@EnvironmentStateObject` in the **[Documentation]**.

Check out the **[GRDBQuery demo apps]**, and the **[GRDB demo apps]** for various examples.

## Thanks

🙌 `@Query` was vastly inspired from [Core Data and SwiftUI](https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/) by [@davedelong](https://github.com/davedelong), with [a critical improvement](https://github.com/groue/GRDB.swift/pull/955) contributed by [@steipete](https://github.com/steipete), and enhancements inspired by conversations with [@stephencelis](https://github.com/stephencelis). Many thanks to all of you!


[GRDB]: http://github.com/groue/GRDB.swift
[GRDB demo apps]: https://github.com/groue/GRDB.swift/tree/master/Documentation/DemoApps
[Documentation]: https://swiftpackageindex.com/groue/GRDBQuery/documentation
[GRDBQuery demo apps]: Documentation
