import Combine
import XCTest
import GRDB
import GRDBQuery

class ObservationQueryableTests: XCTestCase {
    func test_initial_value_is_fetched_immediately() throws {
        struct Request: ObservationQueryable {
            static var defaultValue: Bool { false }
            
            func fetch(_ db: Database) throws -> Bool {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let context = DatabaseContext.readOnly { dbQueue }
        let publisher = request.publisher(in: context)
        
        let valueMutex = Mutex(false)
        _ = publisher.sink { completion in
            if case .failure = completion { XCTFail() }
        } receiveValue: { value in
            valueMutex.withLock { $0 = value }
        }
        XCTAssertTrue(valueMutex.withLock { $0 })
    }
    
    func test_initial_value_is_not_fetched_immediately_and_received_on_main_actor_with_delayed_option() throws {
        struct Request: ObservationQueryable {
            static let observationOptions = ObservationOptions.delayed
            static var defaultValue: Bool { false }
            
            func fetch(_ db: Database) throws -> Bool {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let context = DatabaseContext.readOnly { dbQueue }
        let publisher = request.publisher(in: context)
        
        let valueMutex = Mutex(false)
        let expectation = expectation(description: "value")
        let cancellable = publisher.sink { completion in
            if case .failure = completion { XCTFail() }
        } receiveValue: { value in
            MainActor.assumeIsolated {
                valueMutex.withLock { $0 = value }
                expectation.fulfill()
            }
        }
        XCTAssertFalse(valueMutex.withLock { $0 })
        withExtendedLifetime(cancellable) {
            wait(for: [expectation])
        }
        XCTAssertTrue(valueMutex.withLock { $0 })
    }
}
