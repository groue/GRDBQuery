import Combine
import SwiftUI

public struct QueryPublisherPrintConfiguration {
    public let prefix: String
    public let outputStream: (any TextOutputStream)?
    
    public init(prefix: String = "", outputStream: (any TextOutputStream)? = nil) {
        self.prefix = prefix
        self.outputStream = outputStream
    }
}

// See Documentation.docc/Extensions/Query.md
@propertyWrapper
@MainActor public struct Query<Request: Queryable> {
    /// For a full discussion of these cases, see <doc:QueryableParameters>.
    private enum Configuration {
        case constant(Request)
        case initial(Request)
        case binding(Binding<Request>)
    }
    
    /// Database access
    @Environment private var database: Request.Context
    
    /// Database access
    @Environment(\.queryObservationEnabled) private var queryObservationEnabled
    
    /// The object that keeps on observing the database as long as it is alive.
    @StateObject private var tracker = Tracker()
    
    /// The `Query` configuration.
    private let configuration: Configuration
    private let printPublisherConfiguration: QueryPublisherPrintConfiguration?
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
    
    /// Creates a `Query`, given an initial ``Queryable`` request, and a 
    /// key path to a database context in the SwiftUI environment.
    ///
    /// The `request` must have a `Context` type identical to the type of
    /// `keyPath` in the environment. It can be ``DatabaseContext`` (the
    /// default context of queryable requests), of any other type (see
    /// <doc:CustomDatabaseContexts>).
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query(PlayersRequest(), in: \.myDatabase)
    ///     private var players: [Player]
    ///
    ///     var body: some View {
    ///         List(players) { player in Text(player.name) }
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
    /// - parameter keyPath: A key path to the database in the environment.
    public init(
        _ request: Request,
        in keyPath: KeyPath<EnvironmentValues, Request.Context>,
        printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil)
    {
        self.init(configuration: .initial(request),
                  in: keyPath,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
    
    /// Creates a `Query`, given a ``Queryable`` request, and a key path to
    /// the database in the SwiftUI environment.
    ///
    /// The `request` must have a `Context` type identical to the type of
    /// `keyPath` in the environment. It can be ``DatabaseContext`` (the
    /// default context of queryable requests), of any other type (see
    /// <doc:CustomDatabaseContexts>).
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
    ///         _players = Query(constant: request, in: \.myDatabase)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in Text(player.name) }
    ///     }
    /// }
    /// ```
    ///
    /// - parameter request: A ``Queryable`` request.
    /// - parameter keyPath: A key path to the database in the environment.
    public init(
        constant request: Request,
        in keyPath: KeyPath<EnvironmentValues, Request.Context>,
        printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil)
    {
        self.init(configuration: .constant(request),
                  in: keyPath,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
    
    /// Creates a `Query`, given a SwiftUI binding to its ``Queryable``
    /// request, and a key path to the database in the SwiftUI environment.
    ///
    /// The `request` must have a `Context` type identical to the type of
    /// `keyPath` in the environment. It can be ``DatabaseContext`` (the
    /// default context of queryable requests), of any other type (see
    /// <doc:CustomDatabaseContexts>).
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
    ///         _players = Query(request, in: \.myDatabase)
    ///     }
    ///
    ///     var body: some View {
    ///         List(players) { player in Text(player.name) }
    ///     }
    /// }
    /// ```
    ///
    /// - parameter request: A SwiftUI binding to a ``Queryable`` request.
    /// - parameter keyPath: A key path to the database in the environment.
    public init(
        _ request: Binding<Request>,
        in keyPath: KeyPath<EnvironmentValues, Request.Context>,
        printPublisherConfiguration: QueryPublisherPrintConfiguration? = nil)
    {
        self.init(configuration: .binding(request),
                  in: keyPath,
                  printPublisherConfiguration: printPublisherConfiguration)
    }
    
    private init(
        configuration: Configuration,
        in keyPath: KeyPath<EnvironmentValues, Request.Context>,
        printPublisherConfiguration: QueryPublisherPrintConfiguration?)
    {
        self._database = Environment(keyPath)
        self.configuration = configuration
        self.printPublisherConfiguration = printPublisherConfiguration
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
    ///
    /// ### Accessing the latest error
    ///
    /// - ``error``
    @dynamicMemberLookup public struct Wrapper {
        fileprivate let query: Query
        
        /// Returns a binding to the ``Queryable`` request itself.
        ///
        /// Learn how to use this binding in the <doc:QueryableParameters> guide.
        @MainActor public var request: Binding<Request> {
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
        
        /// Returns the latest request publisher error.
        ///
        /// This error is set whenever an error occurs when accessing a
        /// database value.
        ///
        /// It is reset to nil when the `Query` is restarted.
        @MainActor public var error: Error? {
            query.tracker.error
        }
        
        /// Returns a binding to the property of the ``Queryable`` request, at
        /// a given key path.
        ///
        /// Learn how to use this binding in the <doc:QueryableParameters> guide.
        @MainActor public subscript<U>(dynamicMember keyPath: WritableKeyPath<Request, U>) -> Binding<U> {
            Binding(
                get: { request.wrappedValue[keyPath: keyPath] },
                set: { request.wrappedValue[keyPath: keyPath] = $0 })
        }
    }
    
    /// The object that keeps on observing the database as long as it is alive.
    @MainActor private class Tracker: ObservableObject {
        /// The database value.
        var value: Request.Value?
        
        /// The latest eventual error.
        var error: Error?
        
        /// The request set by the `Wrapper.request` binding.
        /// When modified, we wait for the next `update` to apply.
        var request: Request?
        
        // Actual subscription
        private var trackedRequest: Request?
        private var cancellable: AnyCancellable?
        
        nonisolated init() { }
        
        func update(
            queryObservationEnabled: Bool,
            configuration queryConfiguration: Configuration,
            printPublisherConfiguration: QueryPublisherPrintConfiguration?,
            database: Request.Context)
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
            error = nil
            
            // Load the publisher
            let publisher: Request.ValuePublisher
            do {
                publisher = try newRequest.publisher(in: database)
            } catch {
                self.error = error
                return
            }
            
            var finalPublisher = publisher.eraseToAnyPublisher()
            
            if let printConfiguration = printPublisherConfiguration {
                finalPublisher = finalPublisher.print(printConfiguration.prefix,
                                                      to: printConfiguration.outputStream)
                .eraseToAnyPublisher()
            }
            
            // Start tracking the new request
            var isUpdating = true
            cancellable = finalPublisher.sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    MainActor.assumeIsolated {
                        if case .failure(let error) = completion {
                            if !isUpdating {
                                // Avoid the runtime warning in the case of publishers
                                // that publish values right on subscription:
                                // > Publishing changes from within view updates is not
                                // > allowed, this will cause undefined behavior.
                                self.objectWillChange.send()
                            }
                            self.error = error
                        }
                    }
                },
                receiveValue: { [weak self] value in
                    guard let self = self else { return }
                    MainActor.assumeIsolated {
                        if !isUpdating {
                            // Avoid the runtime warning in the case of publishers
                            // that publish values right on subscription:
                            // > Publishing changes from within view updates is not
                            // > allowed, this will cause undefined behavior.
                            self.objectWillChange.send()
                        }
                        self.value = value
                    }
                })
            isUpdating = false
        }
    }
}

// Declare `DynamicProperty` conformance in an extension so that DocC does
// not show `update` in the `Query` documentation.
extension Query: DynamicProperty {
    nonisolated public func update() {
        MainActor.assumeIsolated {
            tracker.update(
                queryObservationEnabled: queryObservationEnabled,
                configuration: configuration,
                printPublisherConfiguration: printPublisherConfiguration,
                database: database)
        }
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
