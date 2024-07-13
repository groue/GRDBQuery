import Combine
import GRDB

/// A `Queryable` type that observes the database.
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
/// struct PlayersRequest: ObservationQueryable {
///     static var defaultValue: [Player] = []
///
///     func fetch(_ db: Database) throws -> [Player] {
///         try Player.fetchAll(db)
///     }
/// }
/// ```
///
/// For more information, see
/// <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation>.
public protocol ObservationQueryable: Queryable, Sendable
where Context: TopLevelDatabaseReader,
      ValuePublisher == AnyPublisher<Value, any Error>
{
    /// Options for the database observation.
    ///
    /// By default:
    ///
    /// - The initial value is immediately fetched.
    /// - The tracked database region is not considered constant, which
    ///   prevents some scheduling optimization in demanding applications.
    ///
    /// See ``ObservationOptions`` for more information.
    static var observationOptions: ObservationOptions { get }
    
    /// Returns the observed value.
    func fetch(_ db: Database) throws -> Value
}

extension ObservationQueryable {
    public static var observationOptions: ObservationOptions { .default }
    
    public func publisher(in context: Context) -> ValuePublisher {
        context.publishObservation(
            options: Self.observationOptions,
            value: { try self.fetch($0) })
    }
}

extension TopLevelDatabaseReader {
    /// Returns a publisher of an observed database value.
    ///
    /// - Parameters:
    ///   - defaultValue: The value to publish when database access is
    ///     not available.
    ///   - scheduler: A `ValueObservationScheduler`. By default, fresh
    ///     values are dispatched asynchronously on the main dispatch queue.
    ///   - value: The closure that fetches the observed value.
    func publishObservation<Value>(
        options: ObservationOptions,
        value: @escaping @Sendable (Database) throws -> Value
    ) -> AnyPublisher<Value, any Error> {
        DeferredOnMainActor {
            do {
                let observation: ValueObservation<ValueReducers.Fetch<Value>>
                if options.contains(.constantRegion) {
                    observation = ValueObservation.trackingConstantRegion(value)
                } else {
                    observation = ValueObservation.tracking(value)
                }
                
                let publisher: DatabasePublishers.Value<Value>
                if options.contains(.delayed) {
                    publisher = try reader.publish(observation, scheduling: .async(onQueue: .main))
                } else {
                    publisher = try reader.publish(observation, scheduling: .immediate)
                }
                
                return publisher.eraseToAnyPublisher()
            } catch {
                return Fail(outputType: Value.self, failure: error)
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
    @Environment(\.databaseContext) var databaseContext
    @Query(Request()) var value
    
    var body: some View {
        VStack {
            Text(value, format: .number)
                .contentTransition(.numericText())
                .animation(.default, value: value)
            
            Button {
                try! databaseContext.writer.write { db in
                    try db.execute(sql: "INSERT INTO preview DEFAULT VALUES")
                }
            } label: {
                Text(verbatim: "Increment")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct Request: ObservationQueryable {
    static let defaultValue = 0
    
    func fetch(_ db: Database) throws -> Int {
        try Table("preview").fetchCount(db)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
#Preview {
    let dbQueue = try! DatabaseQueue()
    try! dbQueue.write { db in
        try db.create(table: "preview") { t in
            t.autoIncrementedPrimaryKey("id")
        }
    }
    let context = DatabaseContext.make { dbQueue }
    
    return Preview()
        .databaseContext(context)
}
#endif
