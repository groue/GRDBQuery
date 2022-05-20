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

/// A property wrapper that instantiates an observable object from the
/// SwiftUI environment.
///
/// `@EnvironmentStateObject` is similar to SwiftUI `@StateObject`, and
/// provides the same essential services:
///
/// - `@EnvironmentStateObject` instantiates the observable object right before
///   the initial `body` rendering, and deallocates its when the view is no
///   longer rendered.
/// - When published properties of the observable object change, SwiftUI updates
///   the parts of any view that depend on those properties.
/// - Get a `Binding` to one of the observable object’s properties using the
///   `$` operator.
///
/// What `@EnvironmentStateObject` brings on top of `@StateObject` is the
/// ability to instantiate the observable object from the SwiftUI environment.
///
/// **If you do not need to instantiate your observable object from the SwiftUI
/// environment**, then `@EnvironmentStateObject` is not what you need. Just use
/// the plain `@StateObject` instead.
///
/// **If the lifetime of your observable object is different from the one
/// `@StateObject` would provide**, then `@EnvironmentStateObject` is not what
/// you need. Have a look at `@ObservedObject`, `@EnvironmentObject`, etc.
///
/// > Important: Just as `@StateObject`, `@EnvironmentStateObject`
/// > ties the lifetime of the observable object to the lifetime of the
/// > view identity. Once the observable object has been instantiated (right
/// > before the initial `body` rendering), changes in environment values or
/// > other parameters are just ignored.
/// >
/// > Just like `@StateObject`, you can force a new instantiation of the
/// > observable object by changing the view identity.
///
/// ## Usage
///
/// A typical setup starts from an observable object that requires some
/// dependencies (for example, access to the network, or to a database):
///
/// ```swift
/// import Combine // For ObservableObject
///
/// class MyModel: ObservableObject {
///     let fieldTitle: String
///     @Published var fieldValue: String
///
///     init(database: MyDatabase, network: MyNetwork) { ... }
///
///     func save() { ... }
/// }
/// ```
///
/// The application defines an [EnvironmentKey](https://developer.apple.com/documentation/swiftui/environmentkey)
/// for dependencies in the SwiftUI environment:
///
/// ```swift
/// import SwiftUI
///
/// extension EnvironmentValues {
///     var database: MyService { ... }
///     var network: MyNetwork { ... }
/// }
/// ```
///
/// Now a view can use the `@EnvironmentStateObject` property wrapper:
///
/// ```swift
/// import GRDBQuery
/// import SwiftUI
///
/// struct MyView: View {
///     @EnvironmentStateObject var model: MyModel
///
///     init() {
///         _model = EnvironmentStateObject { env in
///             MyModel(database: env.database, network: env.network)
///         }
///     }
///
///     var body: some View {
///         HStack {
///             TextField(viewModel.fieldTitle, text: $model.fieldValue)
///             Button("save") { viewModel.save() }
///         }
///     }
/// }
/// ```
///
/// ### Configuring the Observable Object
///
/// When the observable object needs some extra configuration, update
/// the initializers:
///
/// ```swift
/// class MyModel: ObservableObject {
///     init(database: MyDatabase, network: MyNetwork, id: String) { ... }
/// }
///
/// struct MyView: View {
///     @EnvironmentStateObject var model: MyModel
///
///     init(id: String) {
///         _model = EnvironmentStateObject { env in
///             MyModel(database: env.database, network: env.network, id: id)
///         }
///     }
/// }
/// ```
///
/// ### Decoupling the View from its Observable Object
///
/// You can have the container view responsible for instantiating the
/// observable object:
///
/// ```swift
/// struct MyView: View {
///     @EnvironmentStateObject var model: MyModel
///
///     init(_ makeModel: @escaping (EnvironmentValue) -> MyModel) {
///         _model = EnvironmentStateObject(makeModel)
///     }
/// }
///
/// struct RootView: View {
///     var body: some View {
///         MyView { env in MyModel(database: env.database, network: env.network) }
///     }
/// }
/// ```
///
/// This technique helps observable objects create other ones:
///
/// ```swift
/// struct RootView: View {
///     @EnvironmentStateObject var rootModel: RootModel
///
///     var body: some View {
///         MyView { _ in rootModel.makeMyModel() }
///     }
/// }
/// ```
///
/// This technique is also useful for generic views that accept various types of
/// observable objects:
///
/// ```swift
/// protocol MyModelProtocol: ObservableObject { ... }
///
/// struct MyView<Model: MyModelProtocol>: View {
///     @EnvironmentStateObject var viewModel: Model
///
///     init(_ makeModel: @escaping (EnvironmentValues) -> Model) {
///         _viewModel = EnvironmentStateObject(makeModel)
///     }
/// }
///
/// class MyModelA: MyModelProtocol { ... }
/// class MyModelB: MyModelProtocol { ... }
///
/// struct RootView: View {
///     @EnvironmentStateObject var viewModel: RootModel
///
///     var body: some View {
///         HStack {
///             MyView { _ in viewModel.makeMyModelA() }
///             MyView { _ in viewModel.makeMyModelB() }
///         }
///     }
/// }
/// ```
///
/// ### SwiftUI Previews
///
/// `@EnvironmentStateObject` supports SwiftUI previews very well. It
/// instantiates observable objects with the expected environment values.
/// For example:
///
/// ```swift
/// struct MyView_Previews: PreviewProvider {
///     static var previews: some View {
///         // Default database and network
///         MyView()
///
///         // Specific database, default network
///         MyView().environment(\.database, .empty)
///
///         // Specific database and network
///         MyView()
///             .environment(\.database, .full)
///             .environment(\.network, .failingMock)
///     }
/// }
/// ```
///
/// ### MVVM
///
/// `@EnvironmentStateObject` exists as a support for MVVM applications that use
/// the SwiftUI environment as a solution for dependency injection. See
/// <doc:MVVM> for more information.
///
/// ## Topics
///
/// ### Creating an Environment State Object
///
/// - ``init(_:)``
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
public struct EnvironmentStateObject<ObjectType>: DynamicProperty
where ObjectType: ObservableObject
{
    /// The environment values.
    @Environment(\.self) private var environmentValues
    
    /// The SwiftUI `StateObject` that deals with the lifetime of the
    /// observable object.
    @StateObject private var core = Core()
    
    /// The closure that creates an instance of the observable object.
    private let makeObject: (EnvironmentValues) -> ObjectType
    
    /// Creates a new ``EnvironmentStateObject`` with a closure that builds an
    /// object from environment values.
    public init(_ makeObject: @escaping (EnvironmentValues) -> ObjectType) {
        self.makeObject = makeObject
    }
    
    /// The underlying object.
    public var wrappedValue: ObjectType {
        // If `core.object` is nil, this means that `wrappedValue` is accessed
        // before `update()` was called, and SwiftUI would provide the expected
        // context in the environment.
        //
        // This is a programmer error. We count on SwiftUI to emit a
        // runtime warning:
        //
        // > Accessing StateObject's object without being installed on a
        // > View. This will create a new instance each time.
        core.object ?? makeObject(environmentValues)
    }
    
    /// A projection that creates bindings to the properties of the
    /// underlying object.
    public var projectedValue: Wrapper {
        Wrapper(object: wrappedValue)
    }
    
    /// Part of the SwiftUI `DynamicProperty` protocol. Do not call this method.
    public func update() {
        if core.object == nil {
            core.object = makeObject(environmentValues)
        }
    }
    
    /// A wrapper of the underlying object that can create bindings to its
    /// properties using dynamic member lookup.
    @dynamicMemberLookup public struct Wrapper {
        fileprivate let object: ObjectType
        
        /// Returns a binding to the resulting value of a given key path.
        public subscript<U>(dynamicMember keyPath: ReferenceWritableKeyPath<ObjectType, U>) -> Binding<U> {
            Binding(
                get: { object[keyPath: keyPath] },
                set: { object[keyPath: keyPath] = $0 })
        }
    }
    
    /// An observable object that keeps a strong reference to the object,
    /// and publishes its changes.
    private class Core: ObservableObject {
        let objectWillChange = PassthroughSubject<ObjectType.ObjectWillChangePublisher.Output, Never>()
        private var cancellable: AnyCancellable?
        
        var object: ObjectType? {
            didSet {
                assert(cancellable == nil, "setter should be called once")
                if let object = object {
                    // Transmit all object changes
                    cancellable = object.objectWillChange.subscribe(objectWillChange)
                }
            }
        }
    }
}
