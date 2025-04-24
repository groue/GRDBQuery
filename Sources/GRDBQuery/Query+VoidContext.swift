import SwiftUI

extension Query where Request.Context == Void {
    /// Creates a `Query`, given an initial ``Queryable`` request that uses
    /// `Void` as a `Context`.
    ///
    /// See ``init(_:in:)-2o5mo`` for more information about the runtime
    /// behavior of the returned `Query`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///
    ///     // PlayersRequest feeds from nothing (Void)
    ///     func publisher(in _: Void) -> AnyPublisher<[Player], Error> {
    ///         ...
    ///     }
    /// }
    ///
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
    public init(_ request: Request,
                printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil) {
        self.init(request,
                  in: \.void,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
    
    /// Creates a `Query`, given a SwiftUI binding to a ``Queryable``
    /// request that uses `Void` as a `Context`.
    ///
    /// See ``init(_:in:)-8jlgq`` for more information about the runtime
    /// behavior of the returned `Query`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///
    ///     // PlayersRequest feeds from nothing (Void)
    ///     func publisher(in _: Void) -> AnyPublisher<[Player], Error> {
    ///         ...
    ///     }
    /// }
    ///
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
    public init(_ request: Binding<Request>,
                printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil) {
        self.init(request,
                  in: \.void,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
    
    /// Creates a `Query`, given a ``Queryable`` request that uses
    /// `Void` as a `Context`.
    ///
    /// See ``init(constant:in:)`` for more information about the runtime
    /// behavior of the returned `Query`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///
    ///     // PlayersRequest feeds from nothing (Void)
    ///     func publisher(in _: Void) -> AnyPublisher<[Player], Error> {
    ///         ...
    ///     }
    /// }
    ///
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
    public init(constant request: Request,
                printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil) {
        self.init(constant:request,
                  in: \.void,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
}

extension EnvironmentValues {
    /// A dummy property with type `Void`, as a support for convenience
    /// ``Query`` initializers with `Request.DatabaseContext == Void`.
    fileprivate var void: Void { () }
}
