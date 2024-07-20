import XCTest
@testable import GRDBQuery

class MainActorSchedulerTests: XCTestCase {
    @MainActor func test_schedule_on_main_actor_is_synchronous() {
        var value = 0
        MainActorScheduler.shared.schedule {
            value = 1
        }
        XCTAssertEqual(value, 1)
    }
    
    @MainActor func test_schedule_on_main_actor_from_dispatch_queue_is_synchronous() {
        let queue = DispatchQueue(label: "test")
        queue.sync {
            XCTAssertTrue(Thread.isMainThread)
            var value = 0
            MainActorScheduler.shared.schedule {
                MainActor.assumeIsolated {
                    value = 1
                }
            }
            XCTAssertEqual(value, 1)
        }
    }

    func test_scheduled_block_is_run_on_main_actor() async {
        await withCheckedContinuation { continuation in
            Task {
                XCTAssertFalse(Thread.isMainThread)
                
                MainActorScheduler.shared.schedule {
                    MainActor.assumeIsolated {
                        continuation.resume()
                    }
                }
            }
        }
    }
}
