import Combine

/// A publisher that hops, if needed, to the main actor before
/// creating and subscribing to the provided deferred publisher.
///
/// If `DeferredOnMainActor` is subscribed from the main
/// actor, then there is no actor hop: the deferred publisher is
/// immediately (synchronously) subscribed.
///
/// For example:
///
/// ```swift
/// // Given this function...
/// @MainActor func makeMyPublisher() -> MyPublisher { ... }
///
/// // ... this publisher can be subscribed from any isolation domain.
/// let publisher = DeferredOnMainActor { makeMyPublisher() }
/// ```
struct DeferredOnMainActor<DeferredPublisher: Publisher>: Publisher {
    typealias Output = DeferredPublisher.Output
    typealias Failure = DeferredPublisher.Failure
    let deferred: @Sendable @MainActor () -> DeferredPublisher
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        Deferred { [deferred] in
            Just(())
                .receive(on: MainActorScheduler.shared)
                .flatMap {
                    MainActor.assumeIsolated {
                        UncheckedSendable(value: deferred())
                    }.value
                }
        }
        .receive(subscriber: subscriber)
    }
}

private struct UncheckedSendable<T>: @unchecked Sendable {
    var value: T
}
