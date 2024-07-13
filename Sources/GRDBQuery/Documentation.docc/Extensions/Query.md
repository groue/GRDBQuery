# ``GRDBQuery/Query``

A property wrapper that subscribes to its `Request` (a ``Queryable`` type), and invalidates a SwiftUI view whenever the database values change.

## Overview

Learn how to use `@Query` in <doc:GettingStarted>.

## Topics

### Creating a @Query from the 'databaseContext' SwiftUI environment.

- ``init(_:)-7u3nj``
- ``init(_:)-8786d``
- ``init(constant:)-20bym``

### Creating a @Query from other database contexts.

- ``init(_:in:)-2o5mo``
- ``init(_:in:)-8jlgq``
- ``init(constant:in:)``

### Getting the Value

- ``wrappedValue``
- ``projectedValue``
- ``Wrapper``

### Debugging Initializers

Those convenience initializers don't need any key path. They fit `Queryable` types that ignore environment values and use `Void` as their `DatabaseContext`.

- ``init(_:)-9bg3k``
- ``init(_:)-81ae1``
- ``init(constant:)-1ko9k``
