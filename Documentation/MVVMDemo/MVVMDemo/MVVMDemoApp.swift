import GRDB
import GRDBQuery
import SwiftUI

@main
struct MVVMDemoApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

// MARK: - Give SwiftUI access to the database
//
// Define a new environment key that grants access to a AppDatabase.
//
// The technique is documented at
// <https://developer.apple.com/documentation/swiftui/environmentkey>.

private struct AppDatabaseKey: EnvironmentKey {
    /// The default appDatabase is an empty in-memory database of players
    static let defaultValue = AppDatabase.empty()
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}

// Convenience `EnvironmentStateObject` initializers for observable objects that
// feed from `AppDatabase`.
extension EnvironmentStateObject where Context == AppDatabase {
    init(_ makeObject: @escaping (AppDatabase) -> ObjectType) {
        self.init(\.appDatabase, makeObject)
    }
}

// Convenience typealias for observable objects that feed from `AppDatabase`.
typealias DatabaseStateObject<ObjectType: ObservableObject> = EnvironmentStateObject<ObjectType, AppDatabase>

// Convenience `Query` initializer for requests that feed from `AppDatabase`.
extension Query where Request.DatabaseContext == AppDatabase {
    init(_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}
