# Migrating an application that uses a database manager

## Is my application concerned?

In such an application, SwiftUI views read and write in the database via a "database manager" that encapsulates a GRDB connection. Some views access the database with the `@Query` property wrapper.

If the application connects to multiple databases, read this guide for an overview of the benefits of GRDBQuery 0.9, but prefer the techniques described in <doc:CustomDatabaseContexts>.  

### Use a DatabaseContext

Before the migration, the application defines a custom environment key for the database manager, as below:

```swift
// BEFORE MIGRATION
private struct PlayerRepositoryKey: EnvironmentKey {
    static let defaultValue = PlayerRepository.empty()
}

extension EnvironmentValues {
    var playerRepository: PlayerRepository {
        get { self[PlayerRepositoryKey.self] }
        set { self[PlayerRepositoryKey.self] = newValue }
    }
}

extension View {
    /// Sets the `playerRepository` environment value.
    func playerRepository(_ repository: PlayerRepository) -> some View {
        environment(\.playerRepository, repository)
    }
}
```

The application may also define extra `Query` initializers for accessing the database manager from the custom environment key:

```swift
// BEFORE MIGRATION
extension Query where Request.DatabaseContext == PlayerRepository {
    init(_ request: Request) { ... }
    init(_ request: Binding<Request>) { ... }
    init(constant request: Request) { ... }
}
```

To migrate:

- ✨ Delete the extra `Query` initializers.

- ✨ Expose a read-only access from the database manager:

    ```swift
    extension PlayerRepository {
        /// Provides a read-only access to the database.
        var reader: GRDB.DatabaseReader { writer }
    }
    ```

- ✨ Set a read-only ``DatabaseContext`` in the SwiftUI environment:

    ```swift
    // AFTER MIGRATION
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

### Simplify queryable types

Before the migration, the application defines queryable types that feed from the database manager:

```swift
// BEFORE MIGRATION
struct PlayersRequest: Queryable {
    static var defaultValue: [Player] { [] }
    
    func publisher(in repository: PlayerRepository) -> AnyPublisher<[Player], Error> {
        ValueObservation
            .tracking { db in try fetchValue(db) }
            .publisher(in: repository.reader, scheduling: .immediate)
            .eraseToAnyPublisher()
    }

    func fetchValue(_ db: Database) throws -> [Player] {
        try Player.fetchAll(db)
    }
}
```

To migrate:

- ✨ Simplify queryable types with the convenience protocols (see ``ValueObservationQueryable`` and its siblings), when possible:

    ```swift
    // AFTER MIGRATION
    struct PlayersRequest: ValueObservationQueryable {
        static var defaultValue: [Player] { [] }
        
        func fetch(_ db: Database) throws -> [Player] {
            try Player.fetchAll(db)
        }
    }
    ```

- ✨ For queryable types that can't use any of the convenience protocols, update the argument of `publisher(in:)` from `DatabaseQueue` to `DatabaseContext`:

    ```swift
    // AFTER MIGRATION
    struct MyCustomRequest: Queryable {
        static var defaultValue: [Player] { [] }
        
        func publisher(in context: DatabaseContext) -> ... {
            // Read from context.reader instead of dbQueue
        }
    }
    ```

See <doc:CustomDatabaseContexts> for more details.
