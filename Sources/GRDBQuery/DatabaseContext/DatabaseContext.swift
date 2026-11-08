import GRDB

// See Documentation.docc/Extensions/DatabaseContext.md
public struct DatabaseContext {
    /// This class is the failure type of `ConnectionResult`, an alternative
    /// to the standard `Result`.
    ///
    /// The reason why it exists is that when the `DatabaseContext` stored
    /// in the SwiftUI environment contains plain `Result` values that wrap
    /// an error (such as read-only contexts that wrap an error in their
    /// writer result), then the SwiftUI views that access the
    /// `DatabaseContext` are refreshed for unrelated environment changes
    /// (see <https://github.com/groue/GRDBQuery/issues/68>).
    ///
    /// Replacing `Result` with `ConnectionResult`, whose failure type is a
    /// class (not a struct), fixes this problem.
    private final class ConnectionFailure {
        let error: any Error
        
        init(error: any Error) {
            self.error = error
        }
    }
    
    private enum ConnectionResult<T> {
        case success(T)
        case failure(ConnectionFailure)
        
        static func failure(_ error: any Error) -> Self {
            ConnectionResult.failure(ConnectionFailure(error: error))
        }
        
        func get() throws -> T {
            switch self {
            case .success(let value):
                return value
            case .failure(let failure):
                throw failure.error
            }
        }
    }
    
    private let readerResult: ConnectionResult<any DatabaseReader>
    private let writerResult: ConnectionResult<any DatabaseWriter>
    
    /// Returns a database writer.
    public var writer: any DatabaseWriter {
        get throws {
            try writerResult.get()
        }
    }
}

extension DatabaseContext: TopLevelDatabaseReader {
    public var reader: any DatabaseReader {
        get throws {
            try readerResult.get()
        }
    }
}

extension DatabaseContext {
    /// A `DatabaseContext` that throws
    /// ``DatabaseContextError/notConnected`` on every database access.
    ///
    /// The ``SwiftUI/EnvironmentValues/databaseContext`` environment key
    /// contains such a database context unless the application
    /// replaces it.
    public static var notConnected: DatabaseContext {
        self.init(
            readerResult: .failure(DatabaseContextError.notConnected),
            writerResult: .failure(DatabaseContextError.notConnected))
    }
    
    /// Creates a read-only `DatabaseContext` from an existing
    /// database connection.
    ///
    /// The input closure is evaluated once. If it throws an error, all
    /// database reads performed from the resulting context throw that
    /// same error.
    ///
    /// Attempts to write to the database through the ``writer`` property
    /// throw ``DatabaseContextError/readOnly``, even if the input
    /// connection can perform writes.
    ///
    /// For example:
    ///
    /// ```swift
    /// import GRDBQuery
    /// import SwiftUI
    ///
    /// @main
    /// struct MyApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             MyView()
    ///         }
    ///         .databaseContext(.readOnly { /* a GRDB connection */ })
    ///     }
    /// }
    /// ```
    public static func readOnly(_ reader: () throws -> any DatabaseReader) -> Self {
        do {
            let reader = try reader()
            return self.init(
                readerResult: .success(reader),
                writerResult: .failure(DatabaseContextError.readOnly))
        } catch {
            return self.init(
                readerResult: .failure(error),
                writerResult: .failure(DatabaseContextError.readOnly))
        }
    }
    
    /// Creates a `DatabaseContext` with read/write access to an existing
    /// database connection.
    ///
    /// The input closure is evaluated once. If it throws an error, all
    /// database operations performed from the resulting context throw that
    /// same error.
    ///
    /// For example:
    ///
    /// ```swift
    /// import GRDBQuery
    /// import SwiftUI
    ///
    /// @main
    /// struct MyApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             MyView()
    ///         }
    ///         .databaseContext(.readWrite { /* a GRDB connection */ })
    ///     }
    /// }
    /// ```
    public static func readWrite(_ writer: () throws -> any DatabaseWriter) -> Self {
        do {
            let writer = try writer()
            return self.init(
                readerResult: .success(writer),
                writerResult: .success(writer))
        } catch {
            return self.init(
                readerResult: .failure(error),
                writerResult: .failure(error))
        }
    }
}

/// An error thrown by `DatabaseContext` when database access is
/// not available.
public enum DatabaseContextError: Error {
    /// Database is not connected.
    case notConnected
    
    /// Write access is not available.
    case readOnly
}
