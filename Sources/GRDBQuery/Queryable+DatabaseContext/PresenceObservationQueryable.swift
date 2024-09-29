import Combine
import GRDB

// See Documentation.docc/Extensions/PresenceObservationQueryable.md
public protocol PresenceObservationQueryable<Context>: Queryable, Sendable
where Context: TopLevelDatabaseReader,
      Value == Presence<WrappedValue>,
      ValuePublisher == AnyPublisher<Value, any Error>,
      Value: Sendable
{
    associatedtype WrappedValue
    
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
    
    /// Returns the observed value, or nil if it does not exist.
    func fetch(_ db: Database) throws -> WrappedValue?
}

extension PresenceObservationQueryable {
    public static var queryableOptions: QueryableOptions { .default }
    public static var defaultValue: Presence<WrappedValue> { .missing }
    
    @MainActor public func publisher(in context: Context) -> ValuePublisher {
        context
            .publishObservation(
                queryableOptions: Self.queryableOptions,
                value: { try self.fetch($0) })
            .scanPresence()
            .eraseToAnyPublisher()
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
@MainActor private struct Preview: View {
    @Environment(\.databaseContext) var databaseContext
    @Query(Request()) var presence
    
    var body: some View {
        VStack {
            switch presence {
            case .existing(let value):
                Text(verbatim: "Exists: \(value)")
                Button {
                    try! databaseContext.writer.write { db in
                        _ = try Table("preview").deleteAll(db)
                    }
                } label: {
                    Text(verbatim: "Delete")
                }
                .tint(.red)
            case .gone(let value):
                Text(verbatim: "Gone: \(value)")
                Button {
                    try! databaseContext.writer.write { db in
                        try db.execute(sql: "INSERT INTO preview DEFAULT VALUES")
                    }
                } label: {
                    Text(verbatim: "Create")
                }
            case .missing:
                Text(verbatim: "Missing")
                Button {
                    try! databaseContext.writer.write { db in
                        try db.execute(sql: "INSERT INTO preview DEFAULT VALUES")
                    }
                } label: {
                    Text(verbatim: "Create")
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

private struct Request: PresenceObservationQueryable {
    func fetch(_ db: Database) throws -> Int? {
        try Int.fetchOne(db, sql: "SELECT id FROM preview")
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
    
    return Preview()
        .databaseContext(.readWrite { dbQueue })
}
#endif
