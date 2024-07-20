import Combine
import XCTest
import GRDB
import GRDBQuery

class PresenceObservationQueryableTests: XCTestCase {
    @MainActor func test_initial_value_is_fetched_immediately() throws {
        struct Request: PresenceObservationQueryable {
            func fetch(_ db: Database) throws -> Bool? {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let context = DatabaseContext.readOnly { dbQueue }
        let publisher = request.publisher(in: context)
        
        let valueMutex = Mutex<Presence<Bool>>(.missing)
        _ = publisher.sink { completion in
            if case .failure = completion { XCTFail() }
        } receiveValue: { value in
            valueMutex.withLock { $0 = value }
        }
        XCTAssertEqual(valueMutex.withLock { $0 }.value, true)
    }
    
    @MainActor func test_initial_value_is_not_fetched_immediately_and_received_on_main_actor_with_async_option() throws {
        struct Request: PresenceObservationQueryable {
            static let queryableOptions = QueryableOptions.async
            
            func fetch(_ db: Database) throws -> Bool? {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let context = DatabaseContext.readOnly { dbQueue }
        let publisher = request.publisher(in: context)
        
        let valueMutex = Mutex<Presence<Bool>>(.missing)
        let expectation = expectation(description: "value")
        let cancellable = publisher.sink { completion in
            if case .failure = completion { XCTFail() }
        } receiveValue: { value in
            MainActor.assumeIsolated {
                valueMutex.withLock { $0 = value }
                expectation.fulfill()
            }
        }
        XCTAssertFalse(valueMutex.withLock { $0 }.exists)
        withExtendedLifetime(cancellable) {
            wait(for: [expectation])
        }
        XCTAssertEqual(valueMutex.withLock { $0 }.value, true)
    }
    
    @MainActor func test_custom_context() throws {
        struct DatabaseManager: TopLevelDatabaseReader {
            var reader: any DatabaseReader
        }
        struct Request: PresenceObservationQueryable {
            typealias Context = DatabaseManager
            
            func fetch(_ db: Database) throws -> Bool? {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let manager = DatabaseManager(reader: dbQueue)
        let publisher = request.publisher(in: manager)
        
        let valueMutex = Mutex<Presence<Bool>>(.missing)
        _ = publisher.sink { completion in
            if case .failure = completion { XCTFail() }
        } receiveValue: { value in
            valueMutex.withLock { $0 = value }
        }
        XCTAssertEqual(valueMutex.withLock { $0 }.value, true)
    }
}
