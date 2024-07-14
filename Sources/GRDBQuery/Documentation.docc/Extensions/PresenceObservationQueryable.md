# ``GRDBQuery/PresenceObservationQueryable``

A convenience `Queryable` type that observes the presence of a value in the database, and remembers its latest state before deletion.

## Example

The sample code below defines `PlayerPresenceRequest`, a `PresenceObservationQueryable` type that publishes the presence of a player in the database, given its id:

```swift
import GRDB
import GRDBQuery

struct PlayerPresenceRequest: PresenceObservationQueryable {
    var playerId: Int64

    func fetch(_ db: Database) throws -> Player? {
        try Player.fetchOne(db, id: playerId)
    }
}
```

This `PlayerPresenceRequest` type will automatically update a SwiftUI view on every database changes, when wrapped by the `@Query` property wrapper:

```swift
import GRDBQuery
import SwiftUI

struct PlayerView: View {
    @Query<PlayerPresenceRequest> var playerPresence: Presence<Player>

    init(playerId: Int64) {
        _playerPresence = Query(constant: PlayerPresenceRequest(playerId: playerId))
    }

    var body: some View {
        switch playerPresence {
        case .missing:
            Text("Player does not exist.")

        case .exists(let player):
            Text("Player \(player.name) exists.")

        case .gone(let player):
            Text("Player \(player.name) no longer exists.")
        }
    }
}
```

See <doc:QueryableParameters> for more explanations about the `PlayerView` initializer.

- Important: Make sure a valid database context has been provided in the environment, or it will be impossible to access the database, and the `@Query` property will emit an error.

- Tip: For more information about database observation, see [GRDB.ValueObservation].

## Topics

### Fetching the database value

- ``fetch(_:)``

### Controlling the observation behavior

- ``queryableOptions``

### Supporting Type

- ``Presence``

[GRDB.ValueObservation]: https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation
