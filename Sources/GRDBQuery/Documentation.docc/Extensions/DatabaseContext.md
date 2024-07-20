# ``GRDBQuery/DatabaseContext``

A `DatabaseContext` gives access to a GRDB database, and feeds the `@Query` property wrapper via the `databaseContext`  SwiftUI environment key.

## Overview

`DatabaseContext` provides a read-only access to a database, as well as an optional write access. It can deal with errors that happen during database initialization.

All ``Queryable`` types, by default, feed from a `DatabaseContext`. This can be configured: see <doc:CustomDatabaseContexts>.

To create a `DatabaseContext`, first [connect to a database](https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections):

```swift
let dbQueue = try DatabaseQueue(path: ...)

// Read-write access
let databaseContext = DatabaseContext.readWrite { dbQueue }

// Read-only access
let databaseContext = DatabaseContext.readOnly { dbQueue }
```

## DatabaseContext and the SwiftUI environment

When put in the SwiftUI environment, a `DatabaseContext` allows SwiftUI views to read, observe, and even write in the database, when desired. For example:

```swift
import GRDBQuery
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyView()
        }
        .databaseContext(/* some DatabaseContext on disk */)
    }
}
```

See <doc:GettingStarted> for more information.

## Creating a DatabaseContext from a database manager

When the application accesses the database through a database manager type, it is still possible to create a `DatabaseContext`, and feed `@Query` property wrappers.

For example, here is how to create a read-only `DatabaseContext` from a `PlayerRepository` database manager:

```swift
extension PlayerRepository: TopLevelDatabaseReader {
    /// Provides a read-only access to the database, or throws an error if
    /// database connection could not be opened.
    var reader: GRDB.DatabaseReader {
        get throws { /* return a DatabaseReader */ }
    }
}

let repository: PlayerRepository = ...
let databaseContext = DatabaseContext.readOnly { try repository.reader }
```

Learn more about the way to use GRDBQuery with database managers in <doc:CustomDatabaseContexts>.

## Topics

### Creating A DatabaseContext

- ``init(_:)``
- ``readOnly(_:)``
- ``notConnected``

### Accessing the database

- ``reader``
- ``writer``

### Supporting Types

- ``DatabaseContextError``
