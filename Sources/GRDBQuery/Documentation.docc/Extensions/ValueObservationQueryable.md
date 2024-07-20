# ``GRDBQuery/ValueObservationQueryable``

A convenience `Queryable` type that observes the database.

## Example

The sample code below defines `PlayersRequest`, a queryable type that publishes the list of players found in the database:

```swift
import GRDB
import GRDBQuery

struct PlayersRequest: ValueObservationQueryable {
    static var defaultValue: [Player] { [] }

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
        List(players) { player in Text(player.name) }
    }
}
```

> Important: Make sure a valid database context has been provided in the environment, or the `@Query` property will emit an ``Query/Wrapper/error``. See <doc:GettingStarted>.

> Tip: Learn how a SwiftUI view can configure a `Queryable` type and control the database values it displays: <doc:QueryableParameters>.

> Tip: For more information about database observation, see [GRDB.ValueObservation].

## Runtime Behavior

By default, a `ValueObservationQueryable` type fetches its initial value as soon as a SwiftUI view needs it, from the main thread. This is undesired when the database fetch is slow, because this blocks the user interface. For slow fetches, use the `.async` option, as below. The SwiftUI view will display the default value until the initial fetch is completed.

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

[GRDB.ValueObservation]: https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation
