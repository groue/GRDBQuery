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

/// A property wrapper type that instantiates an observable object from the
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
/// > view identity. Once the observable object has been instantiated, right
/// > before the initial `body` rendering, changes in environment values or
/// > other parameters are just ignored.
/// >
/// > Just like `@StateObject`, you can force a new instantiation of the
/// > observable object by changing the view identity.
///
/// ## Usage
///
/// A typical setup starts from an observable object that requires some
/// "service" (for example, access to the network, or to a database):
///
/// ```swift
/// import Combine // For ObservableObject
///
/// class MyModel: ObservableObject {
///     let fieldTitle: String
///     @Published var fieldValue: String
///
///     init(service: MyService) { ... }
///
///     func save() { ... }
/// }
/// ```
///
/// The application defines an [EnvironmentKey](https://developer.apple.com/documentation/swiftui/environmentkey)
/// that provides access to this "service" from the SwiftUI environment:
///
/// ```swift
/// import SwiftUI
///
/// extension EnvironmentValues {
///     var service: MyService { ... }
/// }
/// ```
///
/// An example of such environment setup is shown in <doc:GettingStarted>.
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
///             MyModel(service: env.service)
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
/// When the observable object needs a "service" as well as some configuration,
/// just update the initializers:
///
/// ```swift
/// class MyModel: ObservableObject {
///     init(service: MyService, myParameter: Int) { ... }
/// }
///
/// struct MyView: View {
///     @EnvironmentStateObject var model: MyModel
///
///     init(myParameter: Int) {
///         _model = EnvironmentStateObject { env in
///             MyModel(service: env.service, myParameter: myParameter)
///         }
///     }
///
///     var body: some View { ... }
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
///     init(model: @escaping (EnvironmentValue) -> MyModel) {
///         _model = EnvironmentStateObject(model)
///     }
///
///     var body: some View { ... }
/// }
///
/// struct Container: View {
///     var body: some View {
///         MyView { env in MyModel(service: env.service) }
///     }
/// }
/// ```
///
/// This technique helps observable objects create other ones:
///
/// ```swift
/// struct Container: View {
///     @EnvironmentStateObject var containerModel: ContainerModel
///
///     var body: some View {
///         MyView(model: containerModel.makeMyModel)
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
///     @EnvironmentStateObject var model: Model
///
///     init(_ makeObject: @escaping (EnvironmentValues) -> Model) {
///         _model = EnvironmentStateObject(makeObject)
///     }
///
///     var body: some View { ... }
/// }
///
/// class MyModelA: MyModelProtocol { ... }
/// class MyModelB: MyModelProtocol { ... }
///
/// struct Container: View {
///     var body: some View {
///         MyView { env in MyModelA(service: env.service) }
///         MyView { env in MyModelB(service: env.service) }
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
///         // Default environment
///         MyView()
///
///         // Specific environment
///         MyView().environment(\.service, ...)
///     }
/// }
/// ```
@propertyWrapper
public struct EnvironmentStateObject<ObjectType>: DynamicProperty
where ObjectType: ObservableObject
{
    /// The environment values.
    @Environment private var environmentValues: EnvironmentValues
    
    /// The SwiftUI `StateObject` that deals with the lifetime of the
    /// observable object.
    @StateObject private var core = Core()
    
    /// The closure that creates an instance of the observable object.
    private let makeObject: (EnvironmentValues) -> ObjectType
    
    /// Creates a new ``EnvironmentStateObject`` with a closure that builds an
    /// object from environment values.
    public init(_ makeObject: @escaping (EnvironmentValues) -> ObjectType) {
        self._environmentValues = Environment(\.self)
        self.makeObject = makeObject
    }
    
    /// The underlying object.
    public var wrappedValue: ObjectType {
        if let object = core.object {
            return object
        } else {
            // Object is accessed before `update()` was called, and SwiftUI
            // would provide the expected context in the environment.
            //
            // This is a programmer error!
            //
            // We count on the SwiftUI runtime to emit a warning: don't crash
            // and just return some object initialized from an invalid context.
            return makeObject(environmentValues)
        }
    }
    
    /// A projection that creates bindings to the object.
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
