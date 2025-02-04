import Combine
import GRDB

// See Documentation.docc/Extensions/ValueObservationQueryable.md
public protocol ValueObservationQueryable<Context>: Queryable, Sendable
where Context: TopLevelDatabaseReader,
      ValuePublisher == AnyPublisher<Value, any Error>,
      Value: Sendable
{
    /// Options for the database observation.
    ///
    /// By default:
    ///
    /// - The initial value is immediately fetched, right on
    ///   subscription. This might not be suitable for slow
    ///   database accesses.
    /// - The tracked database region is not considered constant, which
    ///   prevents some scheduling optimizations.
    ///
    /// See ``QueryableOptions`` for more options.
    ///
    /// See also ``QueryObservation`` for enabling or disabling database
    /// observation.
    static var queryableOptions: QueryableOptions { get }
    
    /// Returns the observed value.
    func fetch(_ db: Database) throws -> Value
}

extension ValueObservationQueryable {
    public static var queryableOptions: QueryableOptions { .default }
    
    @MainActor public func publisher(in context: Context) -> ValuePublisher {
        context.publishObservation(
            queryableOptions: Self.queryableOptions,
            value: { try self.fetch($0) })
    }
}

extension TopLevelDatabaseReader {
    /// Returns a publisher of an observed database value.
    @MainActor func publishObservation<Value: Sendable>(
        queryableOptions: QueryableOptions,
        value: @escaping @Sendable (Database) throws -> Value
    ) -> AnyPublisher<Value, any Error> {
        let readerResult = Result { try reader }
        return DeferredOnMainActor {
            do {
                let reader = try readerResult.get()
                
                let observation: ValueObservation<ValueReducers.Fetch<Value>>
                if queryableOptions.contains(.constantRegion) {
                    observation = ValueObservation.trackingConstantRegion(value)
                } else {
                    observation = ValueObservation.tracking(value)
                }
                
                let publisher: DatabasePublishers.Value<Value>
                if queryableOptions.contains(.async) {
                    publisher = reader.publish(observation, scheduling: .async(onQueue: .main))
                } else {
                    publisher = reader.publish(observation, scheduling: .immediate)
                }
                
                return publisher.eraseToAnyPublisher()
            } catch {
                return Fail(outputType: Value.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
        .assertNoFailure(if: queryableOptions.contains(.assertNoFailure))
        .eraseToAnyPublisher()
    }
}


extension Publisher {
    func assertNoFailure(if condition: Bool) -> AnyPublisher<Output, Failure> {
        if !condition {
            self.eraseToAnyPublisher()
        } else {
            self.assertNoFailure()
                .setFailureType(to: Failure.self)
                .eraseToAnyPublisher()
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
@MainActor private struct Preview: View {
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
            
            if let error = $value.error {
                Text(String(describing: error))
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }
}

private struct Request: ValueObservationQueryable {
    static let defaultValue = 0
    
    func fetch(_ db: Database) throws -> Int {
        try Table("preview").fetchCount(db)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
#Preview("Success") {
    let dbQueue = try! DatabaseQueue()
    try! dbQueue.write { db in
        try db.create(table: "preview") { t in
            t.autoIncrementedPrimaryKey("id")
        }
    }
    
    return Preview()
        .databaseContext(.readWrite { dbQueue })
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
#Preview("Missing database context") {
    Preview()
}
#endif
