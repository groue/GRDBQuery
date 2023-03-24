# ``GRDBQuery/Query``

A property wrapper that subscribes to its `Request` (a ``Queryable`` type), and invalidates a SwiftUI view whenever the database values change.

## Overview

Learn how to use `@Query` in <doc:GettingStarted>.

## Topics

### Creating a @Query

- ``init(_:in:)-4ubsz``
- ``init(_:in:)-2knwm``
- ``init(constant:in:)``

### Convenience @Query initializers

Those convenience initializers don't need a key path, and require a
`Queryable` type that feeds from `EnvironmentValues` or `Void`. See
<doc:GettingStarted> if you are want to build such convenience
initializers for specific `EnvironmentValues` properties.

- ``init(_:)-53zrh``
- ``init(_:)-10boc``
- ``init(constant:)-8ijp1``
- ``init(_:)-5ucm5``
- ``init(_:)-1fkla``
- ``init(constant:)-1vqnm``

### Getting the Value

- ``wrappedValue``
- ``projectedValue``
- ``Wrapper``

### SwiftUI Integration

- ``update()``
