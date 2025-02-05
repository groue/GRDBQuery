/// Options for ``ValueObservationQueryable``,
/// ``PresenceObservationQueryable``, and ``FetchQueryable``.
///
/// ## Topics
///
/// ### Predefined options
///
/// - ``async``
/// - ``constantRegion``
/// - ``assertNoFailure``
public struct QueryableOptions: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// By default, the initial value is immediately fetched. Use the
    /// `async` option when it should be asynchronously fetched.
    ///
    /// Until the initial value is fetched, the value of the `@Query`
    /// property wrapper is the ``Queryable/defaultValue``.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: ValueObservationQueryable {
    ///     static let queryableOptions = QueryableOptions.async
    ///     static let defaultValue: [Player] = []
    ///
    ///     func fetch(_ db: Database) throws -> [Player] {
    ///         try Player.fetchAll(db)
    ///     }
    /// }
    /// ```
    public static let `async` = QueryableOptions(rawValue: 1 << 0)
    
    /// By default, the tracked database region is not considered constant,
    /// and this prevents some scheduling optimizations. Demanding apps may
    /// use this `constantRegion` option when appropriate. Check the
    /// documentation of
    /// [`GRDB.ValueObservation.trackingConstantRegion(_:)`](https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation/trackingconstantregion(_:))
    /// before using this option.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: ValueObservationQueryable {
    ///     static let queryableOptions = QueryableOptions.constantRegion
    ///     static let defaultValue: [Player] = []
    ///
    ///     func fetch(_ db: Database) throws -> [Player] {
    ///         try Player.fetchAll(db)
    ///     }
    /// }
    /// ```
    ///
    /// This option only applies to ``ValueObservationQueryable`` and
    /// ``PresenceObservationQueryable`` types.
    public static let constantRegion = QueryableOptions(rawValue: 1 << 1)
    
    /// By default, any error that occurs can be accessed using ``Query/Wrapper/error``
    /// and is otherwise ignored.
    /// With this option, errors that happen while accessing the
    /// database terminate the app with a fatal error.
    public static let assertNoFailure = QueryableOptions(rawValue: 1 << 2)
    
    /// The default options.
    public static let `default`: QueryableOptions = []
}
