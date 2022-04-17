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
// Query.swift
//
// A property wrapper inspired from
// https://davedelong.com/blog/2021/04/03/core-data-and-swiftui/
//
// You can copy this file into your project, source code and license.
//

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
/// ## Example
///
/// The sample code below defines `AllPlayers`, a `Queryable` type that
/// publishes the list of players found in the database:
///
/// ```swift
/// import Combine
/// import GRDB
/// import GRDBQuery
///
/// /// Tracks the full list of players
/// struct AllPlayers: Queryable {
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
/// This `AllPlayers` type will automatically update a SwiftUI view on every
/// database changes, when wrapped by the `@Query` property wrapper:
///
/// ```swift
/// import GRDBQuery
/// import SwiftUI
///
/// struct PlayerList: View {
///     @Query(AllPlayers())
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
/// If you need to add parameters to a `Queryable` type, so that you can, for
/// example, sort players by name or by score, and let your SwiftUI view control
/// this ordering, see <doc:QueryableParameters>.
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
/// - ``init(_:in:)``
///
/// ### The Database Value
///
/// - ``wrappedValue``
///
/// ### Modifying the Request
///
/// - ``projectedValue``
///
/// ### SwiftUI Integration
///
/// - ``update()``
@propertyWrapper
public struct Query<Request: Queryable>: DynamicProperty {
    /// Database access
    @Environment private var database: Request.DatabaseContext
    
    /// The object that keeps on observing the database as long as it is alive.
    @StateObject private var tracker = Tracker()
    
    private let initialRequest: Request
    
    /// The last published database value.
    public var wrappedValue: Request.Value {
        tracker.value ?? Request.defaultValue
    }
    
    /// A binding to the request, that lets your views modify it.
    ///
    /// Learn how to use this binding in the <doc:QueryableParameters> guide.
    public var projectedValue: Binding<Request> {
        Binding(
            get: { tracker.request ?? initialRequest },
            set: {
                tracker.needsInitialRequest = false
                tracker.request = $0
            })
    }
    
    /// Creates a `Query`, given a ``Queryable`` request, and a key path to the
    /// database in the SwiftUI environment.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query(AllPlayers(), in: \.dbQueue)
    ///     var players: [Player]
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// ### Making the Environment Key Path Implicit
    ///
    /// Some applications want to create `@Query` without specifying the
    /// key path to the database in each and every view. To do so, add somewhere
    /// in your application a convenience `Query` initializer:
    ///
    /// ```swift
    /// extension Query where Request.DatabaseContext == DatabaseQueue {
    ///     init(_ request: Request) {
    ///         self.init(request, in: \.dbQueue)
    ///     }
    /// }
    /// ```
    ///
    /// This initializer will improve your SwiftUI views:
    ///
    /// ```swift
    /// struct PlayerList: View {
    ///     @Query(AllPlayers()) // Implicit key path to the database
    ///     var players: [Player]
    ///
    ///     var body: some View {
    ///         List(players) { player in ... }
    ///     }
    /// }
    /// ```
    ///
    /// See <doc:GettingStarted> for more guidance about the key path, the type
    /// that provides database access, and how to put it in the
    /// SwiftUI environment.
    ///
    /// - parameter request: A ``Queryable`` request.
    /// - parameter keyPath: A key path to the database in the environment. To
    ///   know which key path you have to provide, and learn how to put the
    ///   database in the environment, see <doc:GettingStarted>.
    public init(
        _ request: Request,
        in keyPath: KeyPath<EnvironmentValues, Request.DatabaseContext>)
    {
        _database = Environment(keyPath)
        initialRequest = request
    }
    
    /// Part of the SwiftUI `DynamicProperty` protocol. Do not call this method.
    public func update() {
        // Feed tracker with necessary information,
        // and make sure tracking has started.
        if tracker.needsInitialRequest {
            tracker.request = initialRequest
        }
        tracker.startTrackingIfNecessary(in: database)
    }
    
    /// The object that keeps on observing the database as long as it is alive.
    private class Tracker: ObservableObject {
        private(set) var value: Request.Value?
        var needsInitialRequest = true
        var request: Request? {
            willSet {
                if request != newValue {
                    // Stop tracking, and tell SwiftUI about the update
                    objectWillChange.send()
                    cancellable = nil
                }
            }
        }
        private var cancellable: AnyCancellable?
        
        init() { }
        
        func startTrackingIfNecessary(in database: Request.DatabaseContext) {
            guard let request = request else {
                // No request set
                return
            }
            
            guard cancellable == nil else {
                // Already tracking
                return
            }
            
            cancellable = request.publisher(in: database).sink(
                receiveCompletion: { _ in
                    // Ignore errors
                },
                receiveValue: { [weak self] value in
                    guard let self = self else { return }
                    // Tell SwiftUI about the new value
                    self.objectWillChange.send()
                    self.value = value
                })
        }
    }
}
