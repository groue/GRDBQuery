# Migrating To GRDBQuery 0.9

GRDBQuery 0.9 makes it easier than ever to feed SwiftUI views with database values.

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

    // BEFORE
    struct PlayersRequest: Queryable {
        static var defaultValue: [Player] { [] }
    
        func publisher(in myDatabase: MyDatabase) throws -> AnyPublisher<[Player], Error> {
            try ValueObservation
                .tracking { db in
                    try Player.fetchAll(db)
                }
                .publisher(in: myDatabase.reader, scheduling: .immediate)
                .eraseToAnyPublisher()
        }
    }
    ```
    
    - Use ``ValueObservationQueryable`` for observing a database value and keeping a SwiftUI view in sync.
    - Use ``PresenceObservationQueryable`` for detecting whether a database value exists or not.
    - Use ``FetchQueryable`` to perform a single fetch, without database observation.

    For your more specific needs, the base `Queryable` protocol still accepts your custom Combine publishers.  

- ✨ The new ``DatabaseContext`` type and the `databaseContext` environment key provides a unified way to read or observe a database from SwiftUI views, and even write into it.    

    See <doc:GettingStarted> for an overview, and <doc:CustomDatabaseContexts> for customization options.

- ✨ The `@Query` property wrapper now exposes its eventual database error. See ``Query/Wrapper/error``.

## Upgrading, in practice  

### Breaking changes

All the new features are opt-in, and your GRDBQuery-powered application should continue to work as it is. There are breaking changes that you should handle, first:

- The minimum Swift version is now 5.10 (Xcode 15.3+).
- GRDBQuery now depends on GRDB. If you do not want to embed GRDB in your application, do not upgrade.
- The `Queryable` has an associated type that was renamed from `DatabaseContext` to `Context`. Performing a find and replace in your application should fix the eventual compiler errors.
- If your project uses the [`DisableOutwardActorInference`](https://github.com/apple/swift-evolution/blob/main/proposals/0401-remove-property-wrapper-isolation.md) upcoming feature of the Swift compiler, you may have to annotate some views as `@MainActor`.
