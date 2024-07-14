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
        .databaseContext(/* some DatabaseContext on disk */)
    }
}
```

SwiftUI previews can use specific, in-memory, databases:

```swift
#Preview("Empty database") {
    MyView()
        .databaseContext(/* empty database */)
}

#Preview("Non-empty database") {
    MyView()
        .databaseContext(/* non-empty database */)
    }
}
```

> Note: Apps that connect to multiple databases need further customization. See <doc:CustomDatabaseContexts>.    

## Define a Queryable type

**Next, define a queryable type that publishes database values.**

For example, let's build `PlayersRequest`, that observes the list of player models, and publishes fresh values whenever the database changes:

```swift
import GRDB
import GRDBQuery

/// Tracks the full list of players
struct PlayersRequest: ValueObservationQueryable {
    static var defaultValue: [Player] = []

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

Those "queryable" types conform to the ``Queryable`` protocol, which feeds the `@Query` property wrapper with a sequence of values over time.

Three extra protocols ``ValueObservationQueryable`` (used in the above example), ``PresenceObservationQueryable``, and ``FetchQueryable`` are derived from `Queryable`. They provide convenience APIs that observe the database or perform a single fetch.

Queryable types can have parameters, so that they can filter or sort a list, fetch a model with a particular identifier, etc. See <doc:QueryableParameters>.

> Note: By default, a `Queryable` type accesses the database through a ``DatabaseContext``. This can be configured: see <doc:CustomDatabaseContexts>.

## Feed a SwiftUI View

**Finally**, define the SwiftUI view that feeds from `PlayersRequest`. It automatically updates its content when the database changes:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Query(PlayersRequest()) private var players: [Player]
    
    var body: some View {
        List(players) { player in
            HStack {
                Text(player.name)
                Text("\(player.score) points")
            }
        }
    }
}
```

> Note: Apps that connect to multiple databases or do not use `DatabaseContext` need to tell the `@Query` property wrapper how to access the database. See <doc:CustomDatabaseContexts>.

> Tip: By default, `@Query` listens to the database values for the whole duration of the presence of the view in the SwiftUI engine.
>
> Apps can spare resources by cancelling the subscription when views are not on screen: see ``QueryObservation``.

## Handling Errors

**When an error occurs in the queryable type**, the `@Query` value is just not updated. If the database is unavailable when the view appears, `@Query` will just output the default value. To check if an error has occurred, test the ``Query/Wrapper/error`` property:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Query(PlayersRequest()) private var players: [Player]
    
    var body: some View {
        if let error = $players.error {
            ContentUnavailableView {
                Label("An error occured", systemImage: "xmark.circle")
            } description: {
                Text(error.localizedDescription)
            }
        } else {
            List(players) { player in
                HStack {
                    Text(player.name)
                    Text("\(player.score) points")
                }
            }
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
    @Environment(\.databaseContext) private var databaseContext
    @Query(PlayersRequest()) private var players: [Player]
    
    var body: some View {
        List(players) { player in
            HStack {
                Text(player.name)
                Text("\(player.score) points")
            }
        }
        .toolbar {
            Button {
                deletePlayers()
            } label: {
                Image(systemName: "trash")
            }
        }
    }

    private func deletePlayers() {
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

> Note: Not all apps want to let SwiftUI views performing such database writes. See <doc:CustomDatabaseContexts> for more information.
