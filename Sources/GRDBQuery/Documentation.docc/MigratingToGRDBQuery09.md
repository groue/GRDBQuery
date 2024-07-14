# Migrating To GRDBQuery 0.9

GRDBQuery 0.9 streamlines the definition of the queryable types that feed the `@Query` property wrapper.

## Overview

GRDBQuery 0.9 makes it even more convenient to feed SwiftUI views from a database with the `@Query` property wrappers.

- ✨ The new ``DatabaseContext`` type and the ``SwiftUI/EnvironmentValues/databaseContext`` environment key provides a unified way to read or observe a database from SwiftUI views, and even write into it.

    See <doc:GettingStarted> for an overview, and <doc:CustomDatabaseContexts> for customization options.

- ✨ New convenience protocols make it easier than ever to observe the database, or perform a single fetch.

    For example, here is how you can observe the list of players:

    ```swift
    // 🤩 No Combine publisher in sight
    struct PlayersRequest: ValueObservationQueryable {
        static var defaultValue: [Player] = []
    
        func fetch(_ db: Database) throws -> [Player] {
            try Player.fetchAll(db)
        }
    }
    ```
    
    See the new convenience protocols at the end of this article.

- ✨ The `@Query` property wrapper now exposes its eventual database error. See ``Query/Wrapper/error``.

## Breaking changes

The new features are opt-in, and your GRDBQuery-powered application should continue to work as it is. The breaking changes are:

- Swift 5.10+, Xcode 15.3+ required.
- The `Queryable` associated type `DatabaseContext` was renamed to `Context`. You should perform a find and replace in your application.
- GRDBQuery now depends on GRDB.
