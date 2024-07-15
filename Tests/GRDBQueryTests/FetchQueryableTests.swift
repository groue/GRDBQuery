import Combine
import XCTest
import GRDB
import GRDBQuery

class FetchQueryableTests: XCTestCase {
    @MainActor func test_value_is_fetched_immediately() throws {
        struct Request: FetchQueryable {
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
    
    @MainActor func test_value_is_not_fetched_immediately_and_received_on_main_actor_with_async_option() throws {
        struct Request: FetchQueryable {
            static let queryableOptions = QueryableOptions.async
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
    
    @MainActor func test_custom_context() throws {
        struct DatabaseManager: TopLevelDatabaseReader {
            var reader: any DatabaseReader
        }
        struct Request: FetchQueryable {
            typealias Context = DatabaseManager
            static var defaultValue: Bool { false }
            
            func fetch(_ db: Database) throws -> Bool {
                true
            }
        }
        
        let request = Request()
        let dbQueue = try DatabaseQueue()
        let manager = DatabaseManager(reader: dbQueue)
        let publisher = request.publisher(in: manager)
        
        let valueMutex = Mutex(false)
        _ = publisher.sink { completion in
            if case .failure = completion { XCTFail() }
        } receiveValue: { value in
            valueMutex.withLock { $0 = value }
        }
        XCTAssertTrue(valueMutex.withLock { $0 })
    }
}
