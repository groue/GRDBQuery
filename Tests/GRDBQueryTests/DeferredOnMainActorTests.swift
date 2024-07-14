#if compiler(>=6)
@preconcurrency import Combine
#else
import Combine
#endif
import XCTest
@testable import GRDBQuery

class DeferredOnMainActorTests: XCTestCase {
    func test_deferred_publisher_is_lazily_instantiated() {
        let instantiatedMutex = Mutex(false)
        _ = DeferredOnMainActor {
            instantiatedMutex.withLock { $0 = true }
            return Just(true)
        }
        XCTAssertFalse(instantiatedMutex.withLock { $0 })
    }
    
    @MainActor func test_deferred_publisher_is_synchronously_subscribed_from_main_actor() {
        let publisher = DeferredOnMainActor {
            Just(true)
        }
        var value = false
        _ = publisher.sink(receiveValue: { value = $0 })
        XCTAssertTrue(value)
    }

    func test_deferred_publisher_is_instantiated_on_main_actor() async {
        let value = await withCheckedContinuation { continuation in
            Task {
                XCTAssertFalse(Thread.isMainThread)
                
                let publisher = DeferredOnMainActor {
                    MainActor.assumeIsolated {
                        Just(true)
                    }
                }
                
                let cancellableMutex = Mutex<AnyCancellable?>(nil)
                cancellableMutex.withLock {
                    $0 = publisher.sink { _ in
                        cancellableMutex.withLock { $0 = nil }
                    } receiveValue: {
                        continuation.resume(returning: $0)
                    }
                }
            }
        }
        XCTAssertEqual(value, true)
    }
}
