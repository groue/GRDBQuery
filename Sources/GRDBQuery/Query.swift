// Copyright (C) 2021 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// =============================================================================
//
// You can copy this file into your project, source code and license.

import Combine
import SwiftUI

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

/// A property wrapper that subscribes to its `Request` (a ``Queryable``
/// type), and invalidates a SwiftUI view whenever the database values change.
///
/// Learn how to use `@Query` in <doc:GettingStarted>.
///
/// ## Topics
///
/// ### Creating a @Query
///
/// - ``init(_:in:)-4ubsz``
/// - ``init(_:in:)-2knwm``
/// - ``init(constant:in:)``
///
/// ### Getting the Value
///
/// - ``wrappedValue``
/// - ``projectedValue``
/// - ``Wrapper``
///
/// ### SwiftUI Integration
///
/// - ``update()``
@propertyWrapper
public struct Query<Request: Queryable>: DynamicProperty {
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
    ///     var players: [Player]
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// > NOTE: After the view has appeared on screen, only the SwiftUI bindings
    /// > returned by the ``projectedValue`` wrapper (`$players`) can update
    /// > the database content visible on screen by changing the request.
    /// > See <doc:QueryableParameters> for more details.
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
    /// For example:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query<PlayersRequest> var players: [Player]
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
    /// > NOTE: The SwiftUI bindings returned by the ``projectedValue`` wrapper
    /// > (`$players`) can not update the database content: the request is
    /// > "constant". See <doc:QueryableParameters> for more details.
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
    ///     @Query<PlayersRequest> var players: [Player]
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
    /// > NOTE: Both the `request` Binding argument, and the SwiftUI bindings
    /// > returned by the ``projectedValue`` wrapper (`$players`) can update
    /// > the database content visible on screen by changing the request.
    /// > See <doc:QueryableParameters> for more details.
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
    
    /// Part of the SwiftUI `DynamicProperty` protocol. Do not call this method.
    public func update() {
        tracker.update(
            queryObservationEnabled: queryObservationEnabled,
            configuration: configuration,
            database: database)
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
        @Published var value: Request.Value?
        
        /// The request set by the `Wrapper.request` binding.
        /// When modified, we wait for the next `update` to apply.
        @Published var request: Request?
        
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
            cancellable = newRequest.publisher(in: database).sink(
                receiveCompletion: { _ in
                    // Ignore errors
                },
                receiveValue: { [weak self] value in
                    guard let self = self else { return }
                    self.value = value
                })
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
