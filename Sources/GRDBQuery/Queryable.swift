import Combine

// See Documentation.docc/Extensions/Queryable.md
public protocol Queryable: Equatable {
    /// The type of the published values.
    associatedtype Value
    
    /// The type that provides database access.
    ///
    /// Any type can fit, as long as the `Queryable` type can build a Combine
    /// publisher from an instance of this type, in the
    /// ``publisher(in:)`` method.
    ///
    /// It may be a `GRDB.DatabaseQueue`, or your custom database manager: see
    /// <doc:GettingStarted> for more guidance.
    associatedtype DatabaseContext
    
    /// The type of the Combine publisher of database values, returned
    /// from ``publisher(in:)``.
    associatedtype ValuePublisher: Publisher where ValuePublisher.Output == Value
    
    /// The default value, used until the Combine publisher publishes its
    /// initial value.
    ///
    /// The default value is unused if the publisher successfully publishes its
    /// initial value right on subscription.
    static var defaultValue: Value { get }
    
    /// Returns a Combine publisher of database values.
    ///
    /// - parameter database: Provides access to the database.
    func publisher(in database: DatabaseContext) -> ValuePublisher
}
