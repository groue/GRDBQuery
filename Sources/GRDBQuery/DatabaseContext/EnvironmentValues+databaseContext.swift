import GRDB
import SwiftUI

private struct DatabaseContextKey: EnvironmentKey {
    static var defaultValue: DatabaseContext {
        DatabaseContext.readOnly {
            throw DatabaseContextError.readAccessUnvailable
        }
    }
}

extension EnvironmentValues {
    /// The current database context.
    public var databaseContext: DatabaseContext {
        get { self[DatabaseContextKey.self] }
        set { self[DatabaseContextKey.self] = newValue }
    }
}

extension View {
    /// Puts a database context in the environment.
    public func databaseContext(_ context: DatabaseContext) -> some View {
        environment(\.databaseContext, context)
    }
}
