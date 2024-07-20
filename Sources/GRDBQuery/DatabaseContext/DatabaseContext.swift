import GRDB

// See Documentation.docc/Extensions/DatabaseContext.md
public struct DatabaseContext {
    private let readerResult: Result<any DatabaseReader, Error>
    private let writerResult: Result<any DatabaseWriter, Error>
    
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
    /// Attempts to write in the database through the ``writer`` property
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
    
    /// Creates a `DatabaseContext` with a read/write access on an existing
    /// database connection.
    ///
    /// The input closure is evaluated once. If it throws an error, all
    /// database accesses performed from the resulting context throw that
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

/// An error thrown by `DatabaseContext` when a database access is
/// not available.
public enum DatabaseContextError: Error {
    /// Database is not connected.
    case notConnected
    
    /// Write access is not available.
    case readOnly
}
