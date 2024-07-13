import Combine
import GRDB

/// A `Queryable` type that performs a single fetch. It is suitable for
/// views that must not change once they have appeared on screen.
///
/// For example:
///
/// ```swift
/// import GRDB
/// import GRDBQuery
///
/// struct PlayersView {
///     @Query(PlayersRequest()) var players: [Player]
/// }
///
/// struct PlayersRequest: FetchQueryable {
///     static var defaultValue: [Player] = []
///
///     func fetch(_ db: Database) throws -> [Player] {
///         try Player.fetchAll(db)
///     }
/// }
/// ```
public protocol FetchQueryable: Queryable, Sendable
where Context: TopLevelDatabaseReader,
      ValuePublisher == AnyPublisher<Value, any Error>
{
    /// Options for the database fetch.
    static var fetchOptions: FetchOptions { get }
    
    /// Returns the fetched value.
    func fetch(_ db: Database) throws -> Value
}

extension FetchQueryable {
    public static var fetchOptions: FetchOptions { .default }
    
    public func publisher(in context: Context) -> ValuePublisher {
        context.publishValue(
            options: Self.fetchOptions,
            value: { try self.fetch($0) })
    }
}

extension TopLevelDatabaseReader {
    /// Returns a publisher of a single database value.
    ///
    /// - Parameters:
    ///   - value: The closure that fetches the value.
    func publishValue<Value>(
        options: FetchOptions,
        value: @escaping @Sendable (Database) throws -> Value
    ) -> AnyPublisher<Value, any Error> {
        DeferredOnMainActor {
            if options.contains(.delayed) {
                do {
                    return try reader
                        .readPublisher(value: value)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(outputType: Value.self, failure: error)
                        .eraseToAnyPublisher()
                }
            } else {
                return Result {
                    try reader.read(value)
                }
                .publisher
                .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
private struct Preview: View {
    @Query(Request()) var value
    
    var body: some View {
        Text(value)
    }
}

private struct Request: FetchQueryable {
    static let defaultValue = ""
    
    func fetch(_ db: Database) throws -> String {
        let version = try String.fetchOne(db, sql: "SELECT SQLITE_VERSION()")!
        return "SQLite version: \(version)"
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
#Preview {
    let dbQueue = try! DatabaseQueue()
    let context = DatabaseContext.make { dbQueue }
    
    return Preview()
        .databaseContext(context)
}
#endif
