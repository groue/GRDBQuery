/// Options for ``FetchQueryable`` and ``ValueObservationQueryable``.
///
/// ## Topics
///
/// ### Predefined options
///
/// - ``delayed``
/// - ``constantRegion``
public struct QueryableOptions: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// By default, the initial value is immediately fetched. Use the
    /// `delayed` option when it should be asynchronously fetched.
    ///
    /// Until the initial value is fetched, the value of the `@Query`
    /// property wrapper is the ``Queryable/defaultValue``.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: ValueObservationQueryable {
    ///     static let queryableOptions = QueryableOptions.delayed
    ///     static let defaultValue: [Player] = []
    ///
    ///     func fetch(_ db: Database) throws -> [Player] {
    ///         try Player.fetchAll(db)
    ///     }
    /// }
    /// ```
    public static let delayed = QueryableOptions(rawValue: 1 << 0)
    
    /// This option only applies to ``ValueObservationQueryable`` types.
    /// By default, the tracked database region is not considered constant,
    /// and this prevents some scheduling optimizations. Demanding apps
    /// may use the `constantRegion` option when appropriate. Check the
    /// documentation of
    /// [`ValueObservation.trackingConstantRegion(_:)`](https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation/trackingconstantregion(_:))
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
    public static let constantRegion = QueryableOptions(rawValue: 1 << 1)
    
    /// The default options.
    public static let `default`: QueryableOptions = []
}
