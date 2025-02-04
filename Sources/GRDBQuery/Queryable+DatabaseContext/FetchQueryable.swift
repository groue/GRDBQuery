import Combine
import GRDB

// See Documentation.docc/Extensions/FetchQueryable.md
public protocol FetchQueryable<Context>: Queryable, Sendable
where Context: TopLevelDatabaseReader,
      ValuePublisher == AnyPublisher<Value, any Error>
{
    /// Options for the database fetch.
    ///
    /// The default behavior immediately fetches the value, right on
    /// subscription. This might not be suitable for slow database accesses.
    ///
    /// See ``QueryableOptions`` for more options.
    static var queryableOptions: QueryableOptions { get }
    
    /// Returns the fetched value.
    func fetch(_ db: Database) throws -> Value
}

extension FetchQueryable {
    public static var queryableOptions: QueryableOptions { .default }
    
    @MainActor public func publisher(in context: Context) -> ValuePublisher {
        context.publishValue(
            queryableOptions: Self.queryableOptions,
            value: { try self.fetch($0) })
    }
}

extension TopLevelDatabaseReader {
    /// Returns a publisher of a single database value.
    @MainActor func publishValue<Value>(
        queryableOptions: QueryableOptions,
        value: @escaping @Sendable (Database) throws -> Value
    ) -> AnyPublisher<Value, any Error> {
        let readerResult = Result { try reader }
        return DeferredOnMainActor {
            do {
                let reader = try readerResult.get()
                
                if queryableOptions.contains(.async) {
                    return reader
                        .readPublisher(value: value)
                        .eraseToAnyPublisher()
                } else {
                    return Result {
                        try reader.read(value)
                    }
                    .publisher
                    .eraseToAnyPublisher()
                }
            } catch {
                return Fail(outputType: Value.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
        .assertNoFailure(if: queryableOptions.contains(.assertNoFailure))
        .eraseToAnyPublisher()
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
@MainActor private struct Preview: View {
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
    
    return Preview()
        .databaseContext(.readWrite { dbQueue })
}
#endif
