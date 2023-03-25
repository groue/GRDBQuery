import Combine
import SwiftUI

// See Documentation.docc/Extensions/Query.md
@propertyWrapper
public struct Query<Request: Queryable> {
    /// For a full discussion of these cases, see <doc:QueryableParameters>.
    private enum Configuration {
        case constant(Request)
        case initial(Request)
        case binding(Binding<Request>)
    }
    
    /// Database access
    @Environment private var database: Request.DatabaseContext
    
    /// Database access
    @Environment(\.queryObservationEnabled) private var queryObservationEnabled
    
    /// The object that keeps on observing the database as long as it is alive.
    @StateObject private var tracker = Tracker()
    
    /// The `Query` configuration.
    private let configuration: Configuration
    
    /// The last published database value.
    public var wrappedValue: Request.Value {
        tracker.value ?? Request.defaultValue
    }
    
    /// A projection of the `Query` that creates bindings to its
    /// ``Queryable`` request.
    ///
    /// Learn how to use this projection in the <doc:QueryableParameters> guide.
    public var projectedValue: Wrapper {
        Wrapper(query: self)
    }
    
    /// Creates a `Query`, given an initial ``Queryable`` request, and a key
    /// path to the database in the SwiftUI environment.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query(PlayersRequest(), in: \.dbQueue)
    ///     private var players: [Player]
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// The returned `@Query` is akin to the SwiftUI `@State`: it is the
    /// single source of truth for the request. In the above example, the
    /// request has no parameter, so it does not matter much. But when the
    /// request can be modified, it starts to be relevant. In particular,
    /// at runtime, after the view has appeared on screen, only the SwiftUI
    /// bindings returned by the ``projectedValue`` wrapper (`$players`)
    /// can update the database content visible on screen by changing the
    /// request.
    ///
    /// See <doc:QueryableParameters> for a longer discussion about
    /// `@Query` initializers.
    ///
    /// - parameter request: An initial ``Queryable`` request.
    /// - parameter keyPath: A key path to the database in the environment. To
    ///   know which key path you have to provide, and learn how to put the
    ///   database in the environment, see <doc:GettingStarted>.
    public init(
        _ request: Request,
        in keyPath: KeyPath<EnvironmentValues, Request.DatabaseContext>)
    {
        self._database = Environment(keyPath)
        self.configuration = .initial(request)
    }
    
    /// Creates a `Query`, given a ``Queryable`` request, and a key path to the
    /// database in the SwiftUI environment.
    ///
    /// The SwiftUI bindings returned by the ``projectedValue`` wrapper
    /// (`$players`) can not update the database content: the request is
    /// "constant". See <doc:QueryableParameters> for more details.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query<PlayersRequest> private var players: [Player]
    ///
    ///     init(constantRequest request: Binding<PlayersRequest>) {
    ///         _players = Query(constant: request, in: \.dbQueue)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// - parameter request: A ``Queryable`` request.
    /// - parameter keyPath: A key path to the database in the environment. To
    ///   know which key path you have to provide, and learn how to put the
    ///   database in the environment, see <doc:GettingStarted>.
    public init(
        constant request: Request,
        in keyPath: KeyPath<EnvironmentValues, Request.DatabaseContext>)
    {
        self._database = Environment(keyPath)
        self.configuration = .constant(request)
    }
    
    /// Creates a `Query`, given a SwiftUI binding to its ``Queryable`` request,
    /// and a key path to the database in the SwiftUI environment.
    ///
    /// Both the `request` Binding argument, and the SwiftUI bindings
    /// returned by the ``projectedValue`` wrapper (`$players`) can update
    /// the database content visible on screen by changing the request.
    /// See <doc:QueryableParameters> for more details.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct RootView {
    ///     @State private var request: PlayersRequest
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
    ///         _players = Query(request, in: \.dbQueue)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// - parameter request: A SwiftUI binding to a ``Queryable`` request.
    /// - parameter keyPath: A key path to the database in the environment. To
    ///   know which key path you have to provide, and learn how to put the
    ///   database in the environment, see <doc:GettingStarted>.
    public init(
        _ request: Binding<Request>,
        in keyPath: KeyPath<EnvironmentValues, Request.DatabaseContext>)
    {
        self._database = Environment(keyPath)
        self.configuration = .binding(request)
    }
    
    /// A wrapper of the underlying `Query` that creates bindings to
    /// its ``Queryable`` request.
    ///
    /// ## Topics
    ///
    /// ### Modifying the Request
    ///
    /// - ``request``
    /// - ``subscript(dynamicMember:)``
    @dynamicMemberLookup public struct Wrapper {
        fileprivate let query: Query
        
        /// Returns a binding to the ``Queryable`` request itself.
        ///
        /// Learn how to use this binding in the <doc:QueryableParameters> guide.
        public var request: Binding<Request> {
            Binding(
                get: {
                    switch query.configuration {
                    case let .constant(request):
                        return request
                    case let .initial(request):
                        return query.tracker.request ?? request
                    case let .binding(binding):
                        return binding.wrappedValue
                    }
                },
                set: { newRequest in
                    switch query.configuration {
                    case .constant:
                        // Constant request does not change
                        break
                    case .initial:
                        query.tracker.objectWillChange.send()
                        query.tracker.request = newRequest
                    case let .binding(binding):
                        query.tracker.objectWillChange.send()
                        binding.wrappedValue = newRequest
                    }
                })
        }
        
        /// Returns a binding to the property of the ``Queryable`` request, at
        /// a given key path.
        ///
        /// Learn how to use this binding in the <doc:QueryableParameters> guide.
        public subscript<U>(dynamicMember keyPath: WritableKeyPath<Request, U>) -> Binding<U> {
            Binding(
                get: { request.wrappedValue[keyPath: keyPath] },
                set: { request.wrappedValue[keyPath: keyPath] = $0 })
        }
    }
    
    /// The object that keeps on observing the database as long as it is alive.
    private class Tracker: ObservableObject {
        /// The database value. Published so that view is redrawn when
        /// the value changes.
        var value: Request.Value?
        
        /// The request set by the `Wrapper.request` binding.
        /// When modified, we wait for the next `update` to apply.
        var request: Request?
        
        // Actual subscription
        private var trackedRequest: Request?
        private var cancellable: AnyCancellable?
        
        func update(
            queryObservationEnabled: Bool,
            configuration queryConfiguration: Configuration,
            database: Request.DatabaseContext)
        {
            // Give up if observation is disabled
            guard queryObservationEnabled else {
                trackedRequest = nil
                cancellable = nil
                return
            }
            
            let newRequest: Request
            switch queryConfiguration {
            case let .initial(initialRequest):
                // Ignore initial request once request has been set by `Wrapper`.
                newRequest = request ?? initialRequest
            case let .constant(constantRequest):
                newRequest = constantRequest
            case let .binding(binding):
                newRequest = binding.wrappedValue
            }
            
            // Give up if the request is already tracked.
            if newRequest == trackedRequest {
                return
            }
            
            // Update inner state.
            trackedRequest = newRequest
            request = newRequest
            
            // Start tracking the new request
            var isUpdating = true
            cancellable = newRequest.publisher(in: database).sink(
                receiveCompletion: { _ in
                    // Ignore errors
                },
                receiveValue: { [weak self] value in
                    guard let self = self else { return }
                    if !isUpdating {
                        // Avoid the runtime warning in the case of publishers
                        // that publish values right on subscription:
                        // > Publishing changes from within view updates is not
                        // > allowed, this will cause undefined behavior.
                        self.objectWillChange.send()
                    }
                    self.value = value
                })
            isUpdating = false
        }
    }
}

// Declare `DynamicProperty` conformance in an extension so that DocC does
// not show `update` in the `Query` documentation.
extension Query: DynamicProperty {
    public func update() {
        tracker.update(
            queryObservationEnabled: queryObservationEnabled,
            configuration: configuration,
            database: database)
    }
}

private struct QueryObservationEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    /// A Boolean value that indicates whether `@Query` property wrappers are
    /// observing their requests.
    public var queryObservationEnabled: Bool {
        get { self[QueryObservationEnabledKey.self] }
        set { self[QueryObservationEnabledKey.self] = newValue }
    }
}
