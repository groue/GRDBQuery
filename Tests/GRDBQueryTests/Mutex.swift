import Foundation

/// A Mutex protects a value with an NSLock.
final class Mutex<T> {
    private var value: T
    private var lock = NSLock()
    
    init(_ value: T) {
        self.value = value
    }

    /// Runs the provided closure while holding a lock on the value.
    ///
    /// - parameter body: A closure that can modify the value.
    func withLock<U>(_ body: (inout T) throws -> U) rethrows -> U {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}

extension Mutex: @unchecked Sendable where T: Sendable { }
