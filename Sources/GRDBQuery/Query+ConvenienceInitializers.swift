import SwiftUI

// MARK: Convenience for Request.DatabaseContext == EnvironmentValues

extension Query where Request.DatabaseContext == EnvironmentValues {
    /// Creates a `Query`, given an initial ``Queryable`` request that feeds
    /// from `EnvironmentValues`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///     func publisher(in env: EnvironmentValues) -> AnyPublisher<[Player], Error> {
    ///         ...
    ///     }
    /// }
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
    /// See ``init(_:in:)-4ubsz`` for more information.
    ///
    /// - parameter request: An initial ``Queryable`` request.
    public init(_ request: Request) {
        self.init(request, in: \.self)
    }
    
    /// Creates a `Query`, given a SwiftUI binding to a ``Queryable``
    /// request that feeds from `EnvironmentValues`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///     func publisher(in env: EnvironmentValues) -> AnyPublisher<[Player], Error> {
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
    ///     @Query<PlayersRequest> var players: [Player]
    ///
    ///     init(_ request: Binding<PlayersRequest>) {
    ///         _players = Query(request)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// See ``init(_:in:)-2knwm`` for more information.
    ///
    /// - parameter request: A SwiftUI binding to a ``Queryable`` request.
    public init(_ request: Binding<Request>) {
        self.init(request, in: \.self)
    }
    
    /// Creates a `Query`, given a ``Queryable`` request that feeds
    /// from `EnvironmentValues`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///     func publisher(in env: EnvironmentValues) -> AnyPublisher<[Player], Error> {
    ///         ...
    ///     }
    /// }
    ///
    /// struct PlayerList: View {
    ///     @Query<PlayersRequest> var players: [Player]
    ///
    ///     init(constantRequest request: Binding<PlayersRequest>) {
    ///         _players = Query(constant: request)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// See ``init(constant:in:)`` for more information.
    ///
    /// - parameter request: A ``Queryable`` request.
    public init(constant request: Request) {
        self.init(constant:request, in: \.self)
    }
}

// MARK: - Convenience for Request.DatabaseContext == Void

extension Query where Request.DatabaseContext == Void {
    /// Creates a `Query`, given an initial ``Queryable`` request that feeds
    /// from `Void`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///     func publisher(in _: Void) -> AnyPublisher<[Player], Error> {
    ///         ...
    ///     }
    /// }
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
    /// See ``init(_:in:)-4ubsz`` for more information.
    ///
    /// - parameter request: An initial ``Queryable`` request.
    public init(_ request: Request) {
        self.init(request, in: \.void)
    }
    
    /// Creates a `Query`, given a SwiftUI binding to a ``Queryable``
    /// request that feeds from `Void`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
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
    ///     @Query<PlayersRequest> var players: [Player]
    ///
    ///     init(_ request: Binding<PlayersRequest>) {
    ///         _players = Query(request)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// See ``init(_:in:)-2knwm`` for more information.
    ///
    /// - parameter request: A SwiftUI binding to a ``Queryable`` request.
    public init(_ request: Binding<Request>) {
        self.init(request, in: \.void)
    }
    
    /// Creates a `Query`, given a ``Queryable`` request that feeds
    /// from `Void`.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayersRequest: Queryable {
    ///     static var defaultValue: [Player] { [] }
    ///     func publisher(in _: Void) -> AnyPublisher<[Player], Error> {
    ///         ...
    ///     }
    /// }
    ///
    /// struct PlayerList: View {
    ///     @Query<PlayersRequest> var players: [Player]
    ///
    ///     init(constantRequest request: Binding<PlayersRequest>) {
    ///         _players = Query(constant: request)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// See ``init(constant:in:)`` for more information.
    ///
    /// - parameter request: A ``Queryable`` request.
    public init(constant request: Request) {
        self.init(constant:request, in: \.void)
    }
}

extension EnvironmentValues {
    /// A dummy property with type `Void`, as a support for convenience
    /// ``Query`` initializers with `Request.DatabaseContext == Void`.
    fileprivate var void: Void { () }
}
