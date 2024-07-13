import Combine
import GRDB

/// A type that provides a read-only database access.
public protocol TopLevelDatabaseReader {
    /// Provides a read-only access to the database.
    @MainActor var reader: any DatabaseReader { get throws }
}

extension TopLevelDatabaseReader where Self: DatabaseReader {
    @MainActor public var reader: any DatabaseReader { self }
}

extension AnyDatabaseReader: TopLevelDatabaseReader { }
extension DatabaseQueue: TopLevelDatabaseReader { }
extension DatabasePool: TopLevelDatabaseReader { }
extension DatabaseSnapshot: TopLevelDatabaseReader { }
extension DatabaseSnapshotPool: TopLevelDatabaseReader { }

extension DatabaseReader {
    // Workaround compiler that won't open the TopLevelDatabaseReader.reader
    // existential
    func publish<R: ValueReducer>(
        _ observation: ValueObservation<R>,
        scheduling: some ValueObservationScheduler)
    -> DatabasePublishers.Value<R.Value>
    {
        observation.publisher(in: self, scheduling: scheduling)
    }
}
