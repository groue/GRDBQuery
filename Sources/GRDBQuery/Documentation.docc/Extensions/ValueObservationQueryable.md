# ``GRDBQuery/ValueObservationQueryable``

A convenience `Queryable` type that observes the database.

## Example

The sample code below defines `PlayersRequest`, a `ValueObservationQueryable` type that publishes the list of players found in the database:

```swift
import GRDB
import GRDBQuery

struct PlayersRequest: ValueObservationQueryable {
    static var defaultValue: [Player] = []

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

This `PlayersRequest` type will automatically update a SwiftUI view on every database changes, when wrapped by the `@Query` property wrapper:

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

- Tip: For more information about database observation, see [GRDB.ValueObservation].

## Topics

### Fetching the database value

- ``fetch(_:)``

### Controlling the observation behavior

- ``queryableOptions``

[GRDB.ValueObservation]: https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation
