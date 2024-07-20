# Migrating an application that directly uses a DatabaseQueue or DatabasePool

## Is my application concerned?

If your application defines SwiftUI views that read and write in the database via a raw GRDB connection (`DatabaseQueue` or `DatabasePool`), and observe the database with the `@Query` property wrapper, then GRDBQuery 0.9 can greatly simplify the your setup.

### Remove the custom environment key

Before the migration, the application defines a custom environment key, as below:

```swift
// BEFORE MIGRATION
private struct DatabaseQueueKey: EnvironmentKey {
    /// The default dbQueue is an empty in-memory database
    static var defaultValue: DatabaseQueue { DatabaseQueue() }
}

extension EnvironmentValues {
    var dbQueue: DatabaseQueue {
        get { self[DatabaseQueueKey.self] }
        set { self[DatabaseQueueKey.self] = newValue }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MyView()
                .environment(\.dbQueue, /* some DatabaseQueue on disk */)
        }
    }
}
```

The application may also define extra `Query` initializers for accessing the `DatabaseQueue` from the custom environment key:

```swift
// BEFORE MIGRATION
extension Query where Request.DatabaseContext == DatabaseQueue {
    init(_ request: Request) { ... }
    init(_ request: Binding<Request>) { ... }
    init(constant request: Request) { ... }
}
```

To migrate:

- ✨ Delete the custom environment key.
- ✨ Delete the extra `Query` initializers
- ✨ Register a `DatabaseContext` instead of the raw `DatabaseQueue`:

    ```swift
    // AFTER MIGRATION
    @main
    struct MyApp: App {
        var body: some Scene {
            WindowGroup {
                MyView()
                    .databaseContext(.readWrite { /* the DatabaseQueue */ })
            }
        }
    }
    ```

### Simplify queryable types

Before the migration, the application defines queryable types that feed from a `DatabaseQueue`:

```swift
// BEFORE MIGRATION
struct PlayersRequest: Queryable {
    static var defaultValue: [Player] { [] }
    
    func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Player], Error> {
        ValueObservation
            .tracking { db in try fetchValue(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
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

### Migrate views that perform writes

Before the migration, the application defines views that write in the database:

```swift
// BEFORE MIGRATION
struct DeletePlayersButton: View {
    @Environment(\.dbQueue) var dbQueue

    var body: some View {
        Button("Delete Players") {
            do {
                try dbQueue.write {
                    try Player.deleteAll(db)
                }
            } catch {
                // Handle error
            }
        }
    }
}
```

To migrate:

- ✨ Replace `dbQueue` with `databaseContext`:

    ```swift
    // AFTER MIGRATION
    struct DeletePlayersButton: View {
        @Environment(\.databaseContext) var databaseContext

        var body: some View {
            Button("Delete Players") {
                do {
                    try databaseContext.writer.write {
                        try Player.deleteAll(db)
                    }
                } catch {
                    // Handle error
                }
            }
        }
    }
    ```
