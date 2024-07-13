/// Options for ``FetchQueryable``.
public struct FetchOptions: OptionSet, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// By default, the value is immediately fetched. Use the `delayed`
    /// option when the value should be asynchronously fetched.
    ///
    /// Until the value is fetched, the value of the `@Query` property
    /// wrapper is the ``Queryable/defaultValue``.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: FetchQueryable {
    ///     static let fetchOptions = FetchOptions.delayed
    ///     static let defaultValue: [Player] = []
    ///
    ///     func fetch(_ db: Database) throws -> [Player] {
    ///         try Player.fetchAll(db)
    ///     }
    /// }
    /// ```
    public static let delayed = FetchOptions(rawValue: 1 << 0)
    
    public static let `default`: FetchOptions = []
}
