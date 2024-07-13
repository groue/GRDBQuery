/// Options for ``ObservationQueryable`` and
/// ``PresenceObservationQueryable``.
public struct ObservationOptions: OptionSet, Sendable {
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
    /// struct PlayersRequest: ObservationOptions {
    ///     static let observationOptions = ObservationOptions.delayed
    ///     static let defaultValue: [Player] = []
    ///
    ///     func fetch(_ db: Database) throws -> [Player] {
    ///         try Player.fetchAll(db)
    ///     }
    /// }
    /// ```
    public static let delayed = ObservationOptions(rawValue: 1 << 0)
    
    /// By default, the tracked database region is not considered constant,
    /// and this prevents some scheduling optimization in demanding
    /// applications. Use the `constantRegion` option when appropriate:
    /// check the documentation of `ValueObservation.trackingConstantRegion`:
    /// <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/valueobservation/trackingconstantregion(_:)>
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: ObservationOptions {
    ///     static let observationOptions = ObservationOptions.constantRegion
    ///     static let defaultValue: [Player] = []
    ///
    ///     func fetch(_ db: Database) throws -> [Player] {
    ///         try Player.fetchAll(db)
    ///     }
    /// }
    /// ```
    public static let constantRegion = ObservationOptions(rawValue: 1 << 1)
    
    public static let `default`: ObservationOptions = []
}
