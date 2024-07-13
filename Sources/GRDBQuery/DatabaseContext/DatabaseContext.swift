import GRDB

/// A `DatabaseContext` provides access to a GRDB database, and feed the
/// SwiftUI `databaseContext` environment key.
///
/// Application can opt in for read-only access when desired. They can also
/// deal with database opening errors by providing a failing database
/// context.
public struct DatabaseContext {
    private let _reader: @MainActor () throws -> any DatabaseReader
    private let _writer: @MainActor () throws -> any DatabaseWriter
    
    /// Creates a `DatabaseContext` with a read/write access.
    public static func make(_ writer: @escaping @MainActor () throws -> any DatabaseWriter) -> Self {
        self.init(_reader: writer, _writer: writer)
    }
    
    /// Creates a read-only `DatabaseContext`.
    ///
    /// Attempts to write in the database throug the ``writer`` property
    /// throw ``DatabaseContextError/writeAccessUnvailable``.
    public static func readOnly(_ reader: @escaping @MainActor () throws -> any DatabaseReader) -> Self {
        self.init(
            _reader: reader,
            _writer: { throw DatabaseContextError.writeAccessUnvailable })
    }
}

extension DatabaseContext: TopLevelDatabaseReader {
    @MainActor public var reader: any DatabaseReader {
        get throws {
            try _reader()
        }
    }
}

extension DatabaseContext: TopLevelDatabaseWriter {
    @MainActor public var writer: any DatabaseWriter {
        get throws {
            try _writer()
        }
    }
}

/// An error thrown when the SwiftUI environment does not provide the
/// required dataase access.
public enum DatabaseContextError: Error {
    /// Read-only access is not available.
    case readAccessUnvailable
    
    /// Read-write access is not available.
    case writeAccessUnvailable
}
