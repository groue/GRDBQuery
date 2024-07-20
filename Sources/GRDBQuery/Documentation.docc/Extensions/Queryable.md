# ``GRDBQuery/Queryable``

A type that feeds the `@Query` property wrapper with a sequence of values over time.

## Overview

The role of a `Queryable` type is to build a Combine publisher of database values, with its ``publisher(in:)`` method. The published values feed SwiftUI views that use the `@Query` property wrapper: each time a new value is published, the view updates accordingly.

A `Queryable` type also provides a ``defaultValue``, which is displayed until the publisher publishes its initial value.

The `Queryable` protocol inherits from the standard `Equatable` protocol so that SwiftUI views can configure the database values they display. See <doc:QueryableParameters> for more information.

## Example

The sample code below defines `PlayersRequest`, a `Queryable` type that publishes the list of players found in a `DatabaseContext`:

```swift
import Combine
import GRDB
import GRDBQuery

/// Tracks the full list of players
struct PlayersRequest: Queryable {
    static var defaultValue: [Player] { [] }

    func publisher(in context: DatabaseContext) throws -> AnyPublisher<[Player], Error> {
        try ValueObservation
            .tracking { db in try Player.fetchAll(db) }
            .publisher(in: context.reader, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
}
```

This `PlayersRequest` type will automatically update a SwiftUI view on every database changes, when wrapped by the `@Query` property wrapper:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Query(PlayersRequest()) private var players: [Player]

    var body: some View {
        List(players) { player in Text(player.name) }
    }
}
```

> Important: Make sure a valid database context has been provided in the environment, or the `@Query` property will emit an ``Query/Wrapper/error``. See <doc:GettingStarted>.

## Convenience database accesses

The `Queryable` protocol can build arbitrary Combine publishers, from a ``DatabaseContext`` or from any other data source (see <doc:CustomDatabaseContexts>). It is very versatile.

However, many views just want to observe the database, or perform a single database fetch.

That's why `Queryable` has three derived protocols that address those use cases specifically: ``ValueObservationQueryable``, ``PresenceObservationQueryable`` and ``FetchQueryable``.

For example, the `PlayersRequest` defined above can be streamlined as below, for an identical behavior:

```swift
struct PlayersRequest: ValueObservationQueryable {
    static var defaultValue: [Player] { [] }

    func fetch(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

## Configurable Queryable Types

A `Queryable` type can have parameters, so that it can filter or sort a list, fetch a model with a particular identifier, etc. See <doc:QueryableParameters>.

## Topics

### Associated Types

- ``Context``
- ``ValuePublisher``
- ``Value``

### Database Values

- ``defaultValue``
- ``publisher(in:)``
