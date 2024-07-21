# ``GRDBQuery``

The SwiftUI companion for GRDB

## Overview

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
            List(model.players) { player in Text(player.name) }
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

## Links

- [GitHub repository](http://github.com/groue/GRDBQuery)
- [GRDB]: the toolkit for SQLite databases, with a focus on application development
- [GRDBQuery demo apps](https://github.com/groue/GRDBQuery/tree/main/Documentation)
- [GRDB demo apps](https://github.com/groue/GRDB.swift/tree/master/Documentation/DemoApps)

## Topics

### Fundamentals

- <doc:MigratingToGRDBQuery09>
- <doc:GettingStarted>
- <doc:QueryableParameters>
- ``Query``
- ``Queryable``
- ``ValueObservationQueryable``
- ``PresenceObservationQueryable``
- ``FetchQueryable``
- ``QueryableOptions``

### Providing a database context

- <doc:CustomDatabaseContexts>
- ``DatabaseContext``
- ``DatabaseContextError``
- ``SwiftUI/View/databaseContext(_:)``
- ``SwiftUI/Scene/databaseContext(_:)``
- ``SwiftUI/EnvironmentValues/databaseContext``
- ``TopLevelDatabaseReader``

### Controlling observation

- ``SwiftUI/View/queryObservation(_:)``
- ``QueryObservation``
- ``SwiftUI/EnvironmentValues/queryObservationEnabled``

### The MVVM architecture

- <doc:MVVM>
- ``EnvironmentStateObject``

[GRDB]: http://github.com/groue/GRDB.swift
