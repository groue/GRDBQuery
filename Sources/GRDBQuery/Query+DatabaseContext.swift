import SwiftUI

extension Query where Request.Context == DatabaseContext {
    /// Creates a `Query` that feeds from the `databaseContext`
    /// environment key, given an initial ``Queryable`` request.
    ///
    /// See ``init(_:in:)-2o5mo`` for more information about the runtime
    /// behavior of the returned `Query`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query(PlayersRequest()) private var players: [Player]
    ///
    ///     var body: some View {
    ///         List(players) { player in Text(player.name) }
    ///     }
    /// }
    /// ```
    ///
    /// - parameter request: An initial ``Queryable`` request.
    public init(
        _ request: Request,
        printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil
    ) {
        self.init(request,
                  in: \.databaseContext,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
    
    /// Creates a `Query` that feeds from the `databaseContext`
    /// environment key, given a ``Queryable`` request.
    ///
    /// See ``init(constant:in:)`` for more information about the runtime
    /// behavior of the returned `Query`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query<PlayersRequest> private var players: [Player]
    ///
    ///     init(constantRequest request: PlayersRequest) {
    ///         _players = Query(constant: request)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in Text(player.name) }
    ///     }
    /// }
    /// ```
    ///
    /// - parameter request: A ``Queryable`` request.
    public init(
        constant request: Request,
        printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil
    ) {
        self.init(constant: request,
                  in: \.databaseContext,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
    
    /// Creates a `Query` that feeds from the `databaseContext`
    /// environment key, given a SwiftUI binding to its
    /// ``Queryable`` request.
    ///
    /// See ``init(_:in:)-8jlgq`` for more information about the runtime
    /// behavior of the returned `Query`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct RootView {
    ///     @State var request: PlayersRequest
    ///
    ///     var body: some View {
    ///         PlayerList($request) // Note the `$request` binding here
    ///     }
    /// }
    ///
    /// struct PlayerList: View {
    ///     @Query<PlayersRequest> private var players: [Player]
    ///
    ///     init(_ request: Binding<PlayersRequest>) {
    ///         _players = Query(request)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in Text(player.name) }
    ///     }
    /// }
    /// ```
    ///
    /// - parameter request: A SwiftUI binding to a ``Queryable`` request.
    public init(
        _ request: Binding<Request>,
        printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil
    ) {
        self.init(request,
                  in: \.databaseContext,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
}
