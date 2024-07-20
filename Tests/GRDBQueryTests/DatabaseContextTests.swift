import GRDB
import XCTest
@testable import GRDBQuery

class DatabaseContextTests: XCTestCase {
    @MainActor func test_relationship_with_TopLevelDatabaseReader_and_main_actor() {
        // This test passes if it compiles without any compiler warning.
        @MainActor struct DatabaseManager: TopLevelDatabaseReader {
            var reader: any DatabaseReader {
                get throws { throw DatabaseContextError.notConnected }
            }
            
            var writer: any DatabaseWriter {
                get throws { throw DatabaseContextError.notConnected }
            }
        }
        
        let manager = DatabaseManager()
        _ = DatabaseContext.readOnly { try manager.reader }
        _ = DatabaseContext.readWrite { try manager.writer }
    }
}
