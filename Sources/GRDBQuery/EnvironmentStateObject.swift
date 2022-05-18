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

/// `@EnvironmentStateObject` is a property wrapper type that instantiates an
/// observable object from an environment value.
///
/// `@EnvironmentStateObject` is similar to SwiftUI `@StateObject`, and
/// provides the same essential services:
///
/// - SwiftUI creates a new instance of the observable object only once for each
///   instance of the view that declares the object.
/// - When published properties of the observable object change, SwiftUI updates
///   the parts of any view that depend on those properties.
/// - Get a `Binding` to one of the observable object’s properties using the
///   `$` operator.
///
/// What `@EnvironmentStateObject` brings on top of `@StateObject` is the
/// ability to instantiate the observable object from an environment value.
///
/// **If you do not need to instantiate your observable object from an
/// environment value, then `EnvironmentStateObject` is probably not what you
/// need.** Just use the plain `@StateObject` instead.
///
/// A typical setup is:
///
/// ```swift
/// import GRDBQuery
///
/// struct MyView: View {
///     @EnvironmentStateObject var model: MyModel
///
///     init() {
///         _model = EnvironmentStateObject(\.dbQueue) { dbQueue in
///             MyModel(dbQueue: dbQueue)
///         }
///     }
///
///     var body: some View {
///         Text(model.title)
///         TextField("some field", text: $model.someField)
///     }
/// }
/// ```
///
/// You can add more configuration in the view initializer:
///
/// ```swift
/// struct MyView: View {
///     @EnvironmentStateObject var model: MyModel
///
///     init(myParameter: ...) {
///         _model = EnvironmentStateObject(\.dbQueue) { dbQueue in
///             MyModel(myParameter: myParameter, dbQueue: dbQueue)
///         }
///     }
/// }
/// ```
///
/// `MyView` can be previewed with specific environment values. The observable
/// object will be instantiated with this specific environment. For example:
///
/// ```swift
/// struct MyView_Previews: PreviewProvider {
///     static var previews: some View {
///         // Default environment
///         MyView()
///
///         // Specific environment
///         MyView().environment(\.dbQueue, ...)
///     }
/// }
/// ```
///
/// Note that environment changes are not reflected by the instantiation of a
/// new observable object. Just as `@StateObject`, `@EnvironmentStateObject`
/// ties the lifetime of the observable object to the lifetime of the
/// view identity.
@propertyWrapper
public struct EnvironmentStateObject<Context, ObjectType>: DynamicProperty
where ObjectType: ObservableObject
{
    /// The environment context.
    @Environment private var context: Context
    
    /// The SwiftUI `StateObject` that deals with the lifetime of the
    /// observable object.
    @StateObject private var core = Core()
    
    /// The closure that creates an instance of the observable object.
    private let makeObject: (Context) -> ObjectType
    
    /// Creates a new ``EnvironmentStateObject`` with a closure that builds a
    /// object from a context.
    public init(
        _ keyPath: KeyPath<EnvironmentValues, Context>,
        _ makeObject: @escaping (Context) -> ObjectType)
    {
        self._context = Environment(keyPath)
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
            return makeObject(context)
        }
    }
    
    /// A projection that creates bindings to the object.
    public var projectedValue: Wrapper {
        Wrapper(object: wrappedValue)
    }
    
    /// Part of the SwiftUI `DynamicProperty` protocol. Do not call this method.
    public func update() {
        if core.object == nil {
            core.object = makeObject(context)
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
