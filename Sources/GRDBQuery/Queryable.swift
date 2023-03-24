import Combine

/// `Queryable` types feed the the ``Query`` property wrapper.
///
/// The role of a `Queryable` type is to build a Combine publisher of database
/// values, with its ``publisher(in:)`` method. The published values feed
/// SwiftUI views that use the `@Query` property wrapper: each time a new value
/// is published, the view updates accordingly.
///
/// A `Queryable` type also provides a ``defaultValue``, which is displayed
/// until the publisher publishes its initial value.
///
/// The `Queryable` protocol inherits from the standard `Equatable` protocol so
/// that SwiftUI views can configure the database values they display.
/// See <doc:QueryableParameters> for more information.
///
/// ## Example
///
/// The sample code below defines `PlayersRequest`, a `Queryable` type that
/// publishes the list of players found in the database:
///
/// ```swift
/// import Combine
/// import GRDB
/// import GRDBQuery
///
/// /// Tracks the full list of players
/// struct PlayersRequest: Queryable {
///     static var defaultValue: [Player] { [] }
///
///     func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<[Player], Error> {
///         ValueObservation
///             .tracking { db in try Player.fetchAll(db) }
///             .publisher(in: dbQueue, scheduling: .immediate)
///             .eraseToAnyPublisher()
///     }
/// }
/// ```
///
/// This `PlayersRequest` type will automatically update a SwiftUI view on every
/// database changes, when wrapped by the `@Query` property wrapper:
///
/// ```swift
/// import GRDBQuery
/// import SwiftUI
///
/// struct PlayerList: View {
///     @Query(PlayersRequest())
///     var players: [Player]
///
///     var body: some View {
///         List(players) { player in ... }
///     }
/// }
/// ```
///
/// For an explanation of how this works, and the required setup, please check
/// <doc:GettingStarted>.
///
/// Learn how a SwiftUI view can configure a `Queryable` type, control the
/// database values it displays, in <doc:QueryableParameters>.
///
/// ## Topics
///
/// ### Associated Types
///
/// - ``DatabaseContext``
/// - ``ValuePublisher``
/// - ``Value``
///
/// ### Database Values
///
/// - ``defaultValue``
/// - ``publisher(in:)``
public protocol Queryable: Equatable {
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
    associatedtype ValuePublisher: Publisher
    
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

extension Queryable {
    /// The type of the published values.
    public typealias Value = ValuePublisher.Output
}
