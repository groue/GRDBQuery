# ``GRDBQuery/FetchQueryable``

A convenience `Queryable` type that emits a single value, from a single database fetch. It is suitable for views that must not change once they have appeared on screen.

## Example

The sample code below defines `PlayersRequest`, a FetchQueryable type that fetches the list of players found in the database:

```swift
import GRDB
import GRDBQuery

struct PlayersRequest: FetchQueryable {
    static var defaultValue: [Player] = []

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

This `PlayersRequest` type can feed a SwiftUI view, when wrapped by the `@Query` property wrapper:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Query(PlayersRequest())
    private var players: [Player]

    var body: some View {
        List(players) { player in ... }
    }
}
```

- Important: Make sure a valid database context has been provided in the environment, or it will be impossible to access the database, and the `@Query` property will emit an error.

- Tip: Learn how a SwiftUI view can configure a `Queryable` type, control the database values it displays, in <doc:QueryableParameters>.

## Topics

### Fetching the database value

- ``fetch(_:)``

### Controlling the fetch behavior

- ``queryableOptions``
