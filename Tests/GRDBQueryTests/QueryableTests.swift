import Combine
import XCTest
import GRDB
import GRDBQuery

class QueryableTests: XCTestCase {
    @MainActor func test_custom_context() throws {
        // This test must compile without any compiler warning.
        struct DatabaseManager { }
        struct Request: Queryable {
            static var defaultValue: Bool { false }
            
            func publisher(in manager: DatabaseManager) -> Just<Bool> {
                Just(true)
            }
        }
        
        let request = Request()
        let manager = DatabaseManager()
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
