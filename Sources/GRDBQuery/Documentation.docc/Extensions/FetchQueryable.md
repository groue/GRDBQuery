# ``GRDBQuery/FetchQueryable``

A convenience `Queryable` type that emits a single value, from a single database fetch. It is suitable for views that must not change once they have appeared on screen.

## Example

The sample code below defines `PlayersRequest`, a queryable type that fetches the list of players found in the database:

```swift
import GRDB
import GRDBQuery

struct PlayersRequest: FetchQueryable {
    static var defaultValue: [Player] { [] }

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

This `PlayersRequest` type can feed a SwiftUI view, when wrapped by the `@Query` property wrapper:

```swift
import GRDBQuery
import SwiftUI

struct PlayerPicker: View {
    @Binding var selection: Player
    @Query(PlayersRequest()) private var players: [Player]
    
    var body: some View {
        Picker("Select player", selection: $selection) {
            ForEach(players) { player in
                Text(player.name).tag(player)
            }
        }
    }
}
```

> Important: Make sure a valid database context has been provided in the environment, or the `@Query` property will emit an ``Query/Wrapper/error``. See <doc:GettingStarted>.

> Tip: Learn how a SwiftUI view can configure a `Queryable` type and control the database values it displays: <doc:QueryableParameters>.

## Runtime Behavior

By default, a `FetchQueryable` type fetches the value as soon as a SwiftUI view needs it, from the main thread. This is undesired when the database fetch is slow, because this blocks the user interface. For slow fetches, use the `.async` option, as below. The SwiftUI view will display the default value until the fetch is completed.

```swift
struct PlayersRequest: FetchQueryable {
    // Opt-in for async fetch
    static let queryableOptions = QueryableOptions.async
    
    static var defaultValue: [Player] { [] }

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

## Topics

### Fetching the database value

- ``fetch(_:)``

### Controlling the runtime behavior

- ``queryableOptions``
