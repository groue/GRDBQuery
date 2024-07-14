import GRDB
import SwiftUI

private struct DatabaseContextKey: EnvironmentKey {
    static var defaultValue: DatabaseContext { .notConnected }
}

extension EnvironmentValues {
    /// The database context used for `@Query` and other database
    /// operations within the SwiftUI environment.
    ///
    /// To set the database context in the environment, use
    /// ``SwiftUI/View/databaseContext(_:)``.
    fileprivate(set) public var databaseContext: DatabaseContext {
        get { self[DatabaseContextKey.self] }
        set { self[DatabaseContextKey.self] = newValue }
    }
}

extension View {
    /// Sets the database context in the SwiftUI environment of the `View`.
    ///
    /// For example:
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     @StateObject private var model = MyAppModel()
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             MyView()
    ///                 .databaseContext(model.databaseContext)
    ///         }
    ///     }
    /// }
    /// ```
    public func databaseContext(_ context: DatabaseContext) -> some View {
        environment(\.databaseContext, context)
    }
}

extension Scene {
    /// Set the database context in the SwiftUI environment of a `Scene`.
    ///
    /// For example:
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     @StateObject private var model = MyAppModel()
    ///
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             MyView()
    ///         }
    ///         .databaseContext(model.databaseContext)
    ///     }
    /// }
    /// ```
    public func databaseContext(_ context: DatabaseContext) -> some Scene {
        environment(\.databaseContext, context)
    }
}
