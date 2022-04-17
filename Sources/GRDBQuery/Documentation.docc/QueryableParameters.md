# Adding Parameters to Queryable Types

Learn how a SwiftUI view can configure the database content it displays.

## Overview

The `@Query` property wrapper feeds a SwiftUI view with the database values published by a ``Queryable`` request. Sometimes, the view needs to configure this request, and control the database values it displays.

As an example, let's consider a SwiftUI list of players that needs to control how the list is ordered: by name, or by score. You will adapt this example to your own needs (sorting, filtering, etc.)

## A Configurable Queryable Type

Let's extend the `AllPlayers` type we have seen in <doc:GettingStarted>. It can now sort players by score, or by name, depending on its `ordering` property:

```swift
struct AllPlayers: Queryable {
    enum Ordering {
        case byScore
        case byName
    }

    /// How players are sorted.
    var ordering: Ordering

    static var defaultValue: [Player] { [] }

    func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Player], Error> {
        ValueObservation
            .tracking { db in try fetchValue(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    private func fetchValue(_ db: Database) throws -> [Player] {
        switch ordering {
        case .byScore:
            return try Player
                .order(Column("score").desc)
                .fetchAll(db)
        case .byName:
            return try Player
                .order(Column("name"))
                .fetchAll(db)
        }
    }
}
```

The `@Query` property wrapper will detect changes in the `ordering` property, and update SwiftUI views accordingly. Such detection is possible because the ``Queryable`` protocol inherits from the standard `Equatable`.

## Modifying the Request from the SwiftUI View

SwiftUI views can change the properties of the Queryable request with the SwiftUI Binding provided by the `@Query` property wrapper:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    // Ordering can change through the $players.ordering binding.
    @Query(AllPlayers(ordering: .byScore))
    var players: [Player]

    var body: some View {
        List(players) { player in
            HStack {
                Text(player.name)
                Spacer()
                Text("\(player.score) points")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ToggleOrderingButton(ordering: $players.ordering)
            }
        }
    }
}

struct ToggleOrderingButton: View {
    @Binding var ordering: AllPlayers.Ordering

    var body: some View {
        switch ordering {
        case .byName:
            Button("By Score") { ordering = .byScore }
        case .byScore:
            Button("By Name") { ordering = .byName }
        }
    }
}
```

## Configuring the Initial Request

The above example has the `PlayerList` view always start with the `.byScore` ordering. When you want to provide the initial ordering as a parameter to your view, modify the sample code as below:

```swift
struct PlayerList: View {
    @Query<AllPlayers>
    var players: [Player]

    init(initialOrdering: AllPlayers.Ordering) {
        _players = Query(AllPlayers(ordering: initialOrdering))
    }

    ...
}
```
