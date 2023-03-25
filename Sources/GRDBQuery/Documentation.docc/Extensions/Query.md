# ``GRDBQuery/Query``

A property wrapper that subscribes to its `Request` (a ``Queryable`` type), and invalidates a SwiftUI view whenever the database values change.

## Overview

Learn how to use `@Query` in <doc:GettingStarted>.

## Topics

### Creating a @Query

- ``init(_:in:)-4ubsz``
- ``init(_:in:)-2knwm``
- ``init(constant:in:)``

### Getting the Value

- ``wrappedValue``
- ``projectedValue``
- ``Wrapper``

### Debugging Initializers

Those convenience initializers don't need any key path. They fit `Queryable` types that ignore environment values and use `Void` as their `DatabaseContext`.

- ``init(_:)-5ucm5``
- ``init(_:)-1fkla``
- ``init(constant:)``
