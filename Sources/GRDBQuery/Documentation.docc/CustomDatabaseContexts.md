# Custom Database Contexts

Control the database accesses in your application.

## Overview

Applications can perform arbitrary read and write database accesses from their SwiftUI views, for convenience, or rapid prototyping. See <doc:GettingStarted> for such a setup.

Some apps have other needs, though:

- An app that wants to enforce **database invariants** must not allow views to perform arbitrary database writes. Database invariants are an important part of application safety, as described in the [GRDB Concurrency Guide](https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/concurrency). 
- An app that connects to **multiple databases** and wants to use the `@Query` property wrapper has to specify which database a `@Query` connects to.

We will address those needs below.

## Removing write access from a DatabaseContext

An application controls the ``DatabaseContext`` that is present in the SwiftUI environment. It is read-only if it is created with the ``DatabaseContext/readOnly(_:)`` factory method, even if its underlying database connection can write.

```swift
import GRDBQuery
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyView()
        }
        .databaseContext(/* some read-only context */)
    }
}
```

With a read-only context, all attempts to perform arbitraty writes via the `databaseContext` environment value throw ``DatabaseContextError/readOnly``. This makes it pratically useless to define views that attempt to do so, so your app won't contain any.

## Controlling writes with a custom database manager

Now that it is impossible to perform arbitraty writes from the `databaseContext` environment value, some applications need views to perform controlled database writes — again, for convenience, or rapid prototyping.

To do that, first define a "database manager" type that declares the set of permitted writes with dedicated methods. For example:

```swift
import GRDB

struct PlayerRepository {
    private let writer: GRDB.DatabaseWriter
}

extension PlayerRepository {
    /// Inserts a player and returns the inserted player.
    func insert(_ player: Player) throws -> Player {
        try writer.write { ... }
    }
    
    /// Deletes all players.
    func deletePlayers() throws {
        try writer.write { ... }
    }
}
```

Next, define a custom SwiftUI environment key that makes it possible to inject the database manager in the environment:

```swift
import SwiftUI

private struct PlayerRepositoryKey: EnvironmentKey {
    /// The default dbQueue is an empty in-memory database
    static var defaultValue: PlayerRepository { /* default PlayerRepository */ }
}

extension EnvironmentValues {
    fileprivate(set) var playerRepository: PlayerRepository {
        get { self[PlayerRepositoryKey.self] }
        set { self[PlayerRepositoryKey.self] = newValue }
    }
}

extension View {
    /// Sets the `playerRepository` environment value.
    func playerRepository(_ repository: PlayerRepository) -> some View {
        self.environment(\.playerRepository, repository)
    }
}
```

Note how the `EnvironmentValues.playerRepository` setter is `fileprivate`. We will see why below.

Now, the application can inject a `PlayerRepository` in the environment, and views can use it to perform allowed writes:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyView()
        }
        .environment(\.playerRepository, /* some repository */)
    }
}

struct DeletePlayersButton: View {
    @Environment(\.playerRepository) private var playerRepository

    var body: some View {
        Button("Delete Players") {
            do {
                try playerRepository.deletePlayers()
            } catch {
                // Handle error 
            }
        }
    }
}
```

At this point, views that use the `@Query` property wrapper will fail, because the SwiftUI environment does not contain any `DatabaseContext`. You can restore read-only access with those two extra changes:

1. Expose a read-only access from the database manager.
2. Update the `View.playerRepository(_:)` method so that it sets a database context that reads through the manager.

```swift
extension PlayerRepository {
    /// Provides a read-only access to the database.
    var reader: GRDB.DatabaseReader { writer }
}

extension View {
    /// Sets both the `playerRepository` (for writes) and `databaseContext`
    /// (for `@Query`) environment values.
    func playerRepository(_ repository: PlayerRepository) -> some View {
        self
            .environment(\.playerRepository, repository)
            .databaseContext(.readOnly { repository.reader })
    }
}
```

This modified version of `View.playerRepository(_:)` explains why the `EnvironmentValues.playerRepository` setter was declared as fileprivate: this guarantees that when a `playerRepository` is set, a read-only `databaseContext` is set as well.

Now everything is working as expected: `@Query` can perform arbitrary reads, and views can perform controlled writes.

## Replacing DatabaseContext with a custom database manager, and connecting to multiple databases

It is also possible to get rid of `DatabaseContext` entirely, and perform all database accesses from a database manager.

This technique can be used to disallow arbitrary reads. It is also useful in applications that connect to multiple databases (just define multiple database managers).   

First, stop defining the `databaseContext` environment value, since it is useless.

For `@Query` to be able to feed from a database manager, it is necessary to instruct `Queryable` types to access the database through this database manager, instead of `DatabaseContext`.

- For ``Queryable`` types, build the publisher from a database manager instead of a database context:

    ```swift
    struct MyRequest: Queryable {
        // Instead of publisher(in context: DatabaseContext) 
        func publisher(in repository: PlayerRepository) -> AnyPublisher<Value, Error> {
            ...
        }
    }
    ```

- For ``FetchQueryable`` and ``ValueObservationQueryable``, have the database manager conform to ``TopLevelDatabaseReader``, and explicitly define the context type in queryable types:

    ```swift
    extension PlayerRepository: TopLevelDatabaseReader {
        /// Provides a read-only access to the database.
        var reader: GRDB.DatabaseReader { writer }
    }

    struct PlayersRequest: ValueObservationQueryable {
        // Opt-out of the default `DatabaseContext`
        typealias Context = PlayerRepository
        
        static var defaultValue: [Player] = []

        func fetch(_ db: Database) throws -> [Player] {
            try Player.fetchAll(db)
        }
    }
    ```

Finally, instruct `@Query` to connect to the desired database manager, with an explicit environment key (see <doc:CustomDatabaseContexts#Controlling-writes-with-a-custom-database-manager> above):

```swift
struct PlayerList: View {
    @Query(PlayersRequest(), in: \.playerRepository) // Explicit environment key
    private var players: [Player]
    
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

> Tip: It is possible to use a `@Query` that connects to a custom database manager without specifying an explicit environment key in each and every view.
>
> To do so, declare somewhere in your application convenience `Query` initializers, as below. To decide which initializer to use, see <doc:QueryableParameters>: 
>
> ```swift
> // Convenience Query initializers for requests
> // that feed from `DatabaseQueue`.
> extension Query where Request.Context == PlayerRepository {
>     /// Creates a `Query` that feeds from the `playerRepository`
>     /// environment key, given an initial `Queryable` request.
>     init(_ request: Request) {
>         self.init(request, in: \.playerRepository)
>     }
>
>     /// Creates a `Query` that feeds from the `playerRepository`
>     /// environment key, given a SwiftUI binding to its
>     /// `Queryable` request.
>     init(_ request: Binding<Request>) {
>         self.init(request, in: \.playerRepository)
>     }
>
>     /// Creates a `Query` that feeds from the `playerRepository`
>     /// environment key, given a `Queryable` request.
>     init(constant request: Request) {
>         self.init(constant: request, in: \.playerRepository)
>     }
> }
> ```
>
> These initializers will streamline your SwiftUI views:
>
> ```swift
> struct PlayerList: View {
>     // Implicitly uses 'playerRepository'
>     @Query(PlayersRequest()) private var players: [Player]
>
>     ...
> }
> ```
