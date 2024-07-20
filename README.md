# GRDBQuery

**Latest release**: December 1, 2023 • [version 0.8.0](https://github.com/groue/GRDBQuery/tree/0.8.0) • [CHANGELOG](CHANGELOG.md)

**Requirements**: iOS 14.0+ / macOS 11+ / tvOS 14.0+ / watchOS 7.0+ &bull; Swift 5.10+ / Xcode 15.3+

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

    /// Tracks the full list of database players
    struct PlayersRequest: ValueObservationQueryable {
        static var defaultValue: [Player] { [] }

        func fetch(_ db: Database) throws -> [Player] {
            try Player.fetchAll(db)
        }
    }
    ```

    See <doc:GettingStarted>.

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
            List(players) { player in Text(player.name) }
        }
    }

    class PlayerListModel: ObservableObject {
        @Published private(set) var players: [Player]
        private var cancellable: DatabaseCancellable?

        init(databaseContext: DatabaseContext) {
            let observation = ValueObservation.tracking { db in
                try Player.fetchAll(db)
            } 
            cancellable = observation.start(in: databaseContext.reader, scheduling: .immediate) { error in
                // Handle error
            } onChange: { players in
                self.players =  players
            }
        }
    }
    ```

    See <doc:MVVM>.

Both techniques can be used in a single application, so that developers can run quick experiments, build versatile previews, and also apply strict patterns and conventions. Pick `@Query`, or `@EnvironmentStateObject`, depending on your needs!

## Documentation

Learn how to use `@Query` and `@EnvironmentStateObject` in the **[Documentation]**.

Check out the **[GRDBQuery demo apps]**, and the **[GRDB demo apps]** for various examples.

## Thanks

🙌 `@Query` was vastly inspired from [Core Data and SwiftUI](https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/) by [@davedelong](https://github.com/davedelong), with [a critical improvement](https://github.com/groue/GRDB.swift/pull/955) contributed by [@steipete](https://github.com/steipete). Many thanks to both of you! `@EnvironmentStateObject` was later introduced because `@Query` does not fit the MVVM architecture. The author sees benefits in both property wrappers.


[GRDB]: http://github.com/groue/GRDB.swift
[GRDB demo apps]: https://github.com/groue/GRDB.swift/tree/master/Documentation/DemoApps
[Documentation]: https://swiftpackageindex.com/groue/GRDBQuery/documentation
[GRDBQuery demo apps]: Documentation
