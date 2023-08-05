#if compiler(>=5.9)
import SwiftUI

// See Documentation.docc/Extensions/EnvironmentState.md
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@propertyWrapper
public struct EnvironmentState<Value>: DynamicProperty
{
    /// The environment values.
    @Environment(\.self) private var environmentValues
    
    /// The SwiftUI `State` that deals with the lifetime of the value.
    @State private var core = Core()
    
    /// The closure that creates an instance of the value.
    private let makeValue: (EnvironmentValues) -> Value
    
    /// Creates a new ``EnvironmentState`` with a closure that builds a
    /// value from environment values.
    public init(_ makeValue: @escaping (EnvironmentValues) -> Value) {
        self.makeValue = makeValue
    }
    
    /// The underlying value.
    public var wrappedValue: Value {
        core.value ?? makeValue(environmentValues)
    }
    
    /// A projection that creates bindings to the properties of the
    /// underlying object.
    public var projectedValue: Wrapper {
        Wrapper(binding: Binding(
            get: { core.value ?? makeValue(environmentValues) },
            set: { core.value = $0 }))
    }
    
    /// Part of the SwiftUI `DynamicProperty` protocol. Do not call this method.
    public func update() {
        core.update(makeValue: { makeValue(environmentValues) })
    }
    
    /// A wrapper of the underlying object that can create bindings to its
    /// properties using dynamic member lookup.
    @dynamicMemberLookup public struct Wrapper {
        fileprivate let binding: Binding<Value>
        
        /// Returns a binding to the resulting value of a given key path.
        public subscript<U>(dynamicMember keyPath: WritableKeyPath<Value, U>) -> Binding<U> {
            Binding(
                get: { binding.wrappedValue[keyPath: keyPath] },
                set: { binding.wrappedValue[keyPath: keyPath] = $0 })
        }
    }
    
    /// An observable value that keeps a strong reference to the value,
    /// and publishes its changes.
    @Observable
    class Core {
        var value: Value?
        
        func update(makeValue: () -> Value) {
            guard value == nil else { return }
            let value = makeValue()
            self.value = value
        }
    }
}
#endif

