# Getting Started with @Query

A step-by-step guide for using `@Query` in a SwiftUI application. 

## The SwiftUI Environment

**To use `@Query`, first put a database context in the SwiftUI environment.**

The simplest way to do it is to provide a ``DatabaseContext`` to a SwiftUI View or Scene:

```swift
import GRDBQuery
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyView()
        }
        .databaseContext(.readWrite { /* a GRDB connection */ })
    }
}
```

SwiftUI previews can use specific, in-memory, databases:

```swift
#Preview {
    MyView()
        .databaseContext(.readWrite { /* the database to preview */ })
}
```

To prevent SwiftUI views from writing in the database, use ``DatabaseContext/readOnly(_:)`` instead of ``DatabaseContext/readWrite(_:)``.

Apps that connect to multiple databases need further customization.

See <doc:CustomDatabaseContexts>.    

## Define a Queryable type

**Next, define a queryable type that publishes database values.**

For example, let's build `PlayersRequest`, that observes the list of player models, and publishes fresh values whenever the database changes:

```swift
import GRDB
import GRDBQuery

/// Tracks the full list of players
struct PlayersRequest: ValueObservationQueryable {
    static var defaultValue: [Player] { [] }

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

Such a "queryable" type conforms to the ``Queryable`` protocol. It publishes a sequence of values over time, for the `@Query` property wrapper used in SwiftUI views.

There are three extra protocols: ``ValueObservationQueryable`` (used in the above example), ``PresenceObservationQueryable``, and ``FetchQueryable``. They are derived from `Queryable`, and provide convenience APIs for observing the database, or performing a single fetch.

Queryable types support customization:

- They can have parameters, so that they can filter or sort a list, fetch a model with a particular identifier, etc. See <doc:QueryableParameters>.
- By default, they access the database through a ``DatabaseContext``. This can be configured: see <doc:CustomDatabaseContexts>.

## Feed a SwiftUI View

**Finally**, define the SwiftUI view that feeds from `PlayersRequest`. It automatically updates its content when the database changes:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Query(PlayersRequest()) var players: [Player]
    
    var body: some View {
        List(players) { player in Text(player.name) }
    }
}
```

Apps that connect to multiple databases, or do not use `DatabaseContext`, need to instruct `@Query` how to access the database. See <doc:CustomDatabaseContexts>.

> Tip: By default, `@Query` listens to the database values for the whole duration of the presence of the view in the SwiftUI engine.
>
> Apps can spare resources by stopping and restarting the database observation when views appear and disappear: see ``QueryObservation``.

## Handling Errors

**When an error occurs in the queryable type**, the `@Query` value is just not updated. If the database is unavailable when the view appears, `@Query` will just output the default value. To check if an error has occurred, test the ``Query/Wrapper/error`` property:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Query(PlayersRequest()) var players: [Player]
    
    var body: some View {
        if let error = $players.error {
            ContentUnavailableView {
                Label("An error occured", systemImage: "xmark.circle")
            } description: {
                Text(error.localizedDescription)
            }
        } else {
            List(players) { player in Text(player.name) }
        }
    }
}
```


## Writing into the database

Apps can, when desired, write in the database with the ``SwiftUI/EnvironmentValues/databaseContext`` environment key:

```swift
import GRDB
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Environment(\.databaseContext) var databaseContext
    @Query(PlayersRequest()) var players: [Player]
    
    var body: some View {
        List(players) { player in
            List(players) { player in Text(player.name) }
        }
        .toolbar {
            Button("Delete All") {
                deletePlayers()
            }
        }
    }

    func deletePlayers() {
        do {
            try databaseContext.writer.write { db in
                try Player.deleteAll(db)
            }
        } catch {
            // Handle error
        }
    }
}
```

It is possible to prevent SwiftUI views from performing such unrestricted writes. See ``DatabaseContext/readOnly(_:)`` and <doc:CustomDatabaseContexts> for more information.
