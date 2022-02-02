# @Query

**Latest release**: November 25, 2021 • [version 0.1.0](https://github.com/groue/GRDBQuery/tree/0.1.0) • [CHANGELOG](CHANGELOG.md)

**Requirements**: iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+ &bull; Swift 5.5+ / Xcode 13+

---

This package provides the `@Query` property wrapper, that lets your SwiftUI views automatically update their content when the database changes.

```swift
import GRDBQuery
import SwiftUI

/// A view that displays an always up-to-date list of players in the database.
struct PlayerList: View {
    @Query(AllPlayers())
    var players: [Player]
    
    var body: some View {
        List(players) { player in
            Text(player.name)
        }
    }
}
```

`@Query` is for [GRDB] what [`@FetchRequest`](https://developer.apple.com/documentation/swiftui/fetchrequest) is for Core Data. Although `@Query` does not depend on GRDB, it was designed with GRDB in mind.

- [Why @Query?]
- [Usage]
- [How to Handle Database Errors?]
- [Demo Application]

## Why @Query?

**`@Query` solves a tricky SwiftUI challenge.** It makes sure SwiftUI views are *immediately* rendered with the database content you expect.

For example, when you display a `List` that animates its changes, you do not want to see an animation for the *initial* state of the list, or to prevent this undesired animation with extra code.

You also want your SwiftUI previews to display the expected values *without having to run them*.

Techniques based on [`onAppear(perform:)`](https://developer.apple.com/documentation/swiftui/view/onappear(perform:)), [`onReceive(_:perform)`](https://developer.apple.com/documentation/swiftui/view/onreceive(_:perform:)) and similar methods suffer from this "double-rendering" problem and its side effects. By contrast, `@Query` has you fully covered.

## Usage

**To use `@Query`, first define a new environment key that grants access to the database.**

In the example below, we define a new `dbQueue` environment key whose value is a GRDB [DatabaseQueue]. Some other apps, like the [GRDB demo apps], can choose another name and another type, such as a "database manager" that encapsulates database accesses.

The [EnvironmentKey](https://developer.apple.com/documentation/swiftui/environmentkey) documentation describes the procedure:

```swift
import GRDB
import SwiftUI

private struct DatabaseQueueKey: EnvironmentKey {
    /// The default dbQueue is an empty in-memory database
    static var defaultValue: DatabaseQueue { DatabaseQueue() }
}

extension EnvironmentValues {
    var dbQueue: DatabaseQueue {
        get { self[DatabaseQueueKey.self] }
        set { self[DatabaseQueueKey.self] = newValue }
    }
}
```

You will substitute the default empty database with an actual database on disk for your main application:

```swift
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyView().environment(\.dbQueue, /* some DatabaseQueue on disk */)
        }
    }
}
```

You will feed SwiftUI previews with databases that you want to preview:

```swift
struct PlayerList_Previews: PreviewProvider {
    static var previews: some View {
        // Empty list
        PlayerList().environment(\.dbQueue, /* empty table of players */)
        
        // Non-empty list
        PlayerList().environment(\.dbQueue, /* non-empty table of players */)
    }
}
```

See the [GRDB demo apps] for examples of such setups.

**Next, define a `Queryable` type for each database request you want to observe.**

For example:

```swift
import Combine
import GRDB
import GRDBQuery

/// Tracks the full list of players
struct AllPlayers: Queryable {
    static var defaultValue: [Player] { [] }
    
    func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Player], Error> {
        ValueObservation
            .tracking(Player.fetchAll)
            // The `.immediate` scheduling feeds the view right on subscription,
            // and avoids an initial rendering with an empty list:
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
}
```

The `Queryable` protocol has two requirements: a default value, and a Combine publisher. The publisher is built from the `DatabaseQueue` stored in the environment (you'll adapt this sample code if you prefer another type). The publisher tracks database changes with GRDB [ValueObservation]. The default value is used until the publisher publishes its initial value.

In the above sample code, we make sure the views are *immediately* fed with database content with the `scheduling: .immediate` option. This prevents any "blank state", or "flash of missing content".

The `scheduling: .immediate` option should be removed for database requests that are too slow. In this case, views are initially fed with the default value, and the database content is notified later, when it becomes available. In the meantime, your view can display some waiting indicator, or a [redacted](https://developer.apple.com/documentation/swiftui/view/redacted(reason:)) placeholder. 

**Finally**, you can define a SwiftUI view that automatically updates its content when the database changes:

```swift
import GRDBQuery
import SwiftUI

struct PlayerList: View {
    @Query(AllPlayers(), in: \.dbQueue)
    var players: [Player]
    
    var body: some View {
        List(players) { player in
            HStack {
                Text(player.name)
                Spacer()
                Text("\(player.score) points")
            }
        }
    }
}
```

`@Query` exposes a binding to the request, so that views can change the request when they need. The [GRDB demo apps], for example, use a Queryable type that can change the player ordering:

```swift
struct PlayerList: View {
    // Ordering can change through the $players.ordering binding.
    @Query(AllPlayers(ordering: .byScore))
    var players: [Player]
    ...
}
```

**As a convenience**, you can also define a dedicated `Query` initializer to use the `dbQueue` environment key automatically:

```swift
extension Query where Request.DatabaseContext == DatabaseQueue {
    init(_ request: Request) {
        self.init(request, in: \.dbQueue)
    }
}
```

This improves clarity at the call site:

```swift
struct PlayerList: View {
    @Query(AllPlayers())
    var players: [Player]
    ...
}
```

It is also possible to initialize `@Query` with a `DatabaseQueue` without having it on the environment:
```swift
struct PlayerList: View {
    // Ordering can change through the $players.ordering binding.
    @Query<Player> var players: [Player]
    
    init(database: DatabaseQueue) {
        _players = .init(
            request: AllPlayers(),
            database: database
        )
    }
}
```

## How to Handle Database Errors?

**By default, `@Query` ignores errors** published by `Queryable` types. The SwiftUI views are just not updated whenever an error occurs. If the database is unavailable when the view appears, `@Query` will just output the default value.

You can restore error handling by publishing a `Result`, as in the example below: 

```swift
import Combine
import GRDB
import GRDBQuery

struct AllPlayers: Queryable {
    static var defaultValue: Result<[Player], Error> { .success([]) }
    
    func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<Result<[Player], Error>, Never> {
        ValueObservation
            .tracking(Player.fetchAll)
            .publisher(in: dbQueue, scheduling: .immediate)
            .map { players in .success(players) }
            .catch { error in Just(.failure(error)) }
            .eraseToAnyPublisher()
    }
}
```


## Demo Application

This package ships with a [demo app]. See also the [GRDB demo apps] for various examples of apps that use `@Query`.

---

🙌 `@Query` was vastly inspired from [Core Data and SwiftUI](https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/) by [@davedelong](https://github.com/davedelong), with [a critical improvement](https://github.com/groue/GRDB.swift/pull/955) contributed by [@steipete](https://github.com/steipete). Many thanks to both of you!


[Why @Query?]: #why-query
[Usage]: #usage
[How to Handle Database Errors?]: #how-to-handle-database-errors
[GRDB]: http://github.com/groue/GRDB.swift
[DatabaseQueue]: https://github.com/groue/GRDB.swift/blob/master/README.md#database-queues
[GRDB demo apps]: https://github.com/groue/GRDB.swift/tree/master/Documentation/DemoApps
[demo app]: Documentation/QueryDemo
[Demo Application]: Documentation/QueryDemo
[ValueObservation]: https://github.com/groue/GRDB.swift/blob/master/README.md#valueobservation
