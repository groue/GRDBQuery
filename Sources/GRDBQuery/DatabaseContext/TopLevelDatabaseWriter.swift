import Combine
import GRDB

/// A type that provides a full database access, reads and writes.
public protocol TopLevelDatabaseWriter: TopLevelDatabaseReader {
    /// Returns a database writer.
    @MainActor var writer: any DatabaseWriter { get throws }
}

extension TopLevelDatabaseWriter where Self: DatabaseWriter {
    @MainActor public var writer: any DatabaseWriter { self }
}

extension AnyDatabaseWriter: TopLevelDatabaseWriter { }
extension DatabaseQueue: TopLevelDatabaseWriter { }
extension DatabasePool: TopLevelDatabaseWriter { }
