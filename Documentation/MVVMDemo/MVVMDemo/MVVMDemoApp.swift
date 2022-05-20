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

// In this demo app, some views observe the database with the @Query property
// wrapper. Its documentation recommends to define a dedicated initializer for
// `appDatabase` access, so we comply:

extension Query where Request.DatabaseContext == AppDatabase {
    init(_ request: Request) {
        self.init(request, in: \.appDatabase)
    }
}
