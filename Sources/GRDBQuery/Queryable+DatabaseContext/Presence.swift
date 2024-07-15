import Combine
import GRDB

/// An enum that with three distinct cases, regarding the presence of a
/// value: `.missing`, `.existing`, or `.gone`. The `.gone` case contains
/// the latest known value.
///
/// # Overview
///
/// `Presence` makes it possible to display values on screen, even after
/// they no longer exist. See ``PresenceObservationQueryable`` for a
/// sample code.
///
/// All Combine publishers that publish optional values can be turned into
/// a publisher of `Presence`, with ``Combine/Publisher/scanPresence()``.
public enum Presence<Value> {
    /// The value exists.
    case existing(Value)
    
    /// The value no longer exists, but we have its latest value.
    case gone(Value)
    
    /// The value does not exist, and we don't have any information about it.
    case missing
    
    /// Returns the value, whether it exists or it is gone.
    public var value: Value? {
        switch self {
        case let .existing(value), let .gone(value):
            return value
        case .missing:
            return nil
        }
    }
    
    /// A boolean value indicating whether the value exists.
    public var exists: Bool {
        switch self {
        case .existing:
            return true
        case .gone, .missing:
            return false
        }
    }
}

extension Presence: Equatable where Value: Equatable { }

extension Presence: Hashable where Value: Hashable { }

extension Presence: Identifiable where Value: Identifiable {
    public var id: Value.ID? {
        switch self {
        case .existing(let value):
            return value.id
        case .gone(let value):
            return value.id
        case .missing:
            return nil
        }
    }
}

extension Presence: Sendable where Value: Sendable { }

extension Publisher {
    /// Transforms the upstream publisher of optional values into a
    /// publisher of ``Presence`` that preserves the last non-nil
    /// value.
    ///
    /// For example:
    ///
    ///     publisher   publisher.presence()
    ///     | nil       | .missing
    ///     | 1         | .existing(1)
    ///     | 2         | .existing(2)
    ///     | nil       | .gone(2)
    ///     | nil       | .gone(2)
    ///     | 3         | .existing(3)
    ///     v           v
    public func scanPresence<Value>()
    -> Publishers.Scan<Self, Presence<Value>>
    where Output == Value?
    {
        scan(.missing) { (previous, value) in
            if let value {
                .existing(value)
            } else if let previousValue = previous.value {
                .gone(previousValue)
            } else {
                .missing
            }
        }
    }
}
