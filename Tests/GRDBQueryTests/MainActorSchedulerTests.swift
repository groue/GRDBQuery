import Foundation
import Testing
@testable import GRDBQuery

struct MainActorSchedulerTests {
    @Test @MainActor
    func schedule_on_main_actor_is_synchronous() {
        var value = 0
        MainActorScheduler.shared.schedule {
            value = 1
        }
        #expect(value == 1)
    }
    
    @Test @MainActor
    func schedule_on_main_actor_from_dispatch_queue_is_synchronous() {
        let queue = DispatchQueue(label: "test")
        queue.sync {
            #expect(Thread.isMainThread)
            var value = 0
            MainActorScheduler.shared.schedule {
                MainActor.assumeIsolated {
                    value = 1
                }
            }
            #expect(value == 1)
        }
    }

    @Test
    func scheduled_block_is_run_on_main_actor() async {
        await withCheckedContinuation { continuation in
            Task {
                #expect(!isMainThread())
                
                MainActorScheduler.shared.schedule {
                    MainActor.assumeIsolated {
                        continuation.resume()
                    }
                }
            }
        }
    }
}
