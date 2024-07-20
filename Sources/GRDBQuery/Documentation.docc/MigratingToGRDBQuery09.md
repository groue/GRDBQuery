# Migrating To GRDBQuery 0.9

GRDBQuery 0.9 makes it easier than ever to access the database from SwiftUI views.

## Overview

This release aims at streamlining the application code that feeds the `@Query` property wrapper.

- ✨ You no longer need to write Combine publishers in your queryable types, thanks to new convenience protocols that address the most common use cases.

    For example, here is how you can observe the list of players and keep a SwiftUI view in sync:
    
    ```swift
    // NEW in GRDBQuery 0.9
    struct PlayersRequest: ValueObservationQueryable {
        static var defaultValue: [Player] { [] }
        
        func fetch(_ db: Database) throws -> [Player] {
            try Player.fetchAll(db)
        }
    }

    // BEFORE GRDBQuery 0.9
    struct PlayersRequest: Queryable {
        static var defaultValue: [Player] { [] }
        
        func publisher(in myDatabase: MyDatabase) throws -> AnyPublisher<[Player], Error> {
            try ValueObservation
                .tracking { db in try Player.fetchAll(db) }
                .publisher(in: myDatabase.reader, scheduling: .immediate)
                .eraseToAnyPublisher()
        }
    }    
    ```
    
    - Use ``ValueObservationQueryable`` for observing a database value and keeping a SwiftUI view in sync.
    - Use ``PresenceObservationQueryable`` for observing whether a database value exists or not.
    - Use ``FetchQueryable`` to perform a single fetch, without database observation.
    
    For your more specific needs, the base ``Queryable`` protocol still accepts your custom Combine publishers.  

- ✨ The new ``DatabaseContext`` type and the `databaseContext` environment key provides a unified way to read or observe a database from SwiftUI views. This can remove a lot of boilerplate code, such as a custom environment key, or convenience `Query` initializers from this environment key. 

    See the focused migration guides at the end of this article for more details.

- ✨ The `@Query` property wrapper now exposes its eventual database error. See ``Query/Wrapper/error``.

## Breaking changes

All the new features are opt-in, and your GRDBQuery-powered application should continue to work as it is. There are breaking changes that you may have to handle, though:

- The minimum Swift version is now 5.10 (Xcode 15.3+).
- GRDBQuery now depends on GRDB. If you do not want to embed GRDB in your application, _do not upgrade_, and consider [vendoring](https://stackoverflow.com/questions/26217488/what-is-vendoring) GRDBQuery 0.8.0 in your application.
- The `Queryable` protocol has an associated type that was renamed from `DatabaseContext` to `Context`. Perform a find and replace in your application in order to fix the eventual compiler errors.
- `@Query` is now main-actor isolated. This will automatically isolate views that embed `@Query` to the main actor, and their `async` methods will start running on the main actor as well. This might be undesired, so it is recommended to review the `async` methods of those views. 
- If your project uses the [`DisableOutwardActorInference`](https://github.com/apple/swift-evolution/blob/main/proposals/0401-remove-property-wrapper-isolation.md) upcoming feature of the Swift compiler, in order to avoid the automatic main actor isolation mentioned above, you will have to annotate some views as `@MainActor`.

Once breaking changes are addressed, keep on reading the focused migration guide that fits your app, below.

## Topics

### Focused Migration Guides

- <doc:MigratingToGRDBQuery09-unrestricted-writes>
- <doc:MigratingToGRDBQuery09-restricted-writes>
