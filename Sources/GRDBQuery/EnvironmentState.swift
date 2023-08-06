#if compiler(>=5.9)
import SwiftUI

// See Documentation.docc/Extensions/EnvironmentState.md
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@propertyWrapper
public struct EnvironmentState<Value> {
    private class Container {
        var optionalValue: Value?
        var value: Value {
            get { optionalValue! }
            set { optionalValue = newValue }
        }
    }
    
    /// The environment values.
    @Environment(\.self) private var environmentValues
    
    /// The SwiftUI `State` that deals with the lifetime of the value.
    @State private var container = Container()
    
    /// The closure that creates an instance of the observable object.
    private let makeValue: (EnvironmentValues) -> Value
    
    /// Creates a new ``EnvironmentState`` with a closure that builds a
    /// value from environment values.
    public init(makeValue: @escaping (EnvironmentValues) -> Value) {
        self.makeValue = makeValue
    }
    
    /// The underlying value.
    public var wrappedValue: Value {
        makeValueIfNeeded()
        return container.value
    }
    
    /// A binding to the state value.
    public var projectedValue: Binding<Value> {
        makeValueIfNeeded()
        return $container.value
    }
    
    private func makeValueIfNeeded() {
        if container.optionalValue == nil {
            container.optionalValue = makeValue(environmentValues)
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension EnvironmentState: DynamicProperty {
    public func update() {
        makeValueIfNeeded()
    }
}
#endif
