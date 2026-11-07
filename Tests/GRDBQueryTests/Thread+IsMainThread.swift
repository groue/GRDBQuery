import Foundation

/// Returns whether the current thread is the main thread.
///
/// Unlike `Thread.isMainThread`, this function is available from
/// asynchronous contexts, such as `#expect` in an async test.
func isMainThread() -> Bool {
    Thread.isMainThread
}
