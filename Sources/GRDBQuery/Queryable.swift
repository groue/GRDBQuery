import Combine

// See Documentation.docc/Extensions/Queryable.md
public protocol Queryable<Context>: Equatable {
    /// The type of the published values.
    associatedtype Value
    
    /// The type that provides database access.
    ///
    /// By default, it is ``DatabaseContext``.
    ///
    /// Generally speaking, any type can fit, as long as the `Queryable`
    /// type can build a Combine publisher from an instance of this type,
    /// in the ``publisher(in:)`` method.
    ///
    /// It may be a `GRDB.DatabaseQueue`, or your custom database manager:
    /// see <doc:CustomDatabaseContexts> for more guidance.
    associatedtype Context = DatabaseContext
    
    /// The type of the Combine publisher of database values, returned
    /// from ``publisher(in:)``.
    associatedtype ValuePublisher: Publisher where ValuePublisher.Output == Value
    
    /// The default value, used until the Combine publisher publishes its
    /// initial value.
    ///
    /// The default value is unused if the publisher successfully publishes its
    /// initial value right on subscription.
    @MainActor static var defaultValue: Value { get }
    
    /// Returns a Combine publisher of database values.
    ///
    /// The returned publisher must publish its values and completion on the
    /// main actor.
    ///
    /// - parameter database: Provides access to the database.
    /// - throws: Any error that prevents the publisher to be returned.
    @MainActor func publisher(in database: Context) throws -> ValuePublisher
}
