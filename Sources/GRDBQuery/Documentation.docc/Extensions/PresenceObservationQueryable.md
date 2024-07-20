# ``GRDBQuery/PresenceObservationQueryable``

A convenience `Queryable` type that observes the presence of a value in the database, and remembers its latest state before deletion.

## Example

The sample code below defines `PlayerPresenceRequest`, a queryable type that publishes the presence of a player in the database, given its id:

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

> Important: Make sure a valid database context has been provided in the environment, or the `@Query` property will emit an ``Query/Wrapper/error``. See <doc:GettingStarted>.

> Tip: For more information about database observation, see [GRDB.ValueObservation].

## Runtime Behavior

By default, a `PresenceObservationQueryable` type fetches its initial value as soon as a SwiftUI view needs it, from the main thread. This is undesired when the database fetch is slow, because this blocks the user interface. For slow fetches, use the `.async` option, as below. The SwiftUI view will display the default value until the initial fetch is completed.

```swift
struct PlayersRequest: ValueObservationQueryable {
    // Opt-in for async fetch
    static let queryableOptions = QueryableOptions.async
    
    static var defaultValue: [Player] { [] }

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

The other option is ``QueryableOptions/constantRegion``. When appropriate, it that can enable scheduling optimizations in the most demanding apps. Check the documentation of this option.

## Topics

### Fetching the database value

- ``fetch(_:)``

### Controlling the runtime behavior

- ``queryableOptions``

### Support

- ``Presence``
- ``Combine/Publisher/scanPresence()``

[GRDB.ValueObservation]: https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation
