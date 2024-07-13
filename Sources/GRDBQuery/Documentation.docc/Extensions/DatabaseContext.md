# ``GRDBQuery/DatabaseContext``

A `DatabaseContext` provides access to a GRDB database, and feeds the SwiftUI `databaseContext` environment key.

## Overview

`DatabaseContext` provides a read-only access, an optional write access, and can deal with errors that happen during database initialization.

All ``Queryable`` types, by default, feed from a `DatabaseContext`. This can be configured: see <doc:CustomDatabaseContexts>.

To create a `DatabaseContext`, first [connect to a database](https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections):

```swift
let dbQueue = try DatabaseQueue(path: ...)

// Read-write access
let databaseContext = DatabaseContext { dbQueue }

// Read-only access
let databaseContext = DatabaseContext.readOnly { dbQueue }
```

## DatabaseContext and the SwiftUI environment

When put in the SwiftUI environment, a `DatabaseContext` can feed ``Queryable`` types. See <doc:GettingStarted> for more information.

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
